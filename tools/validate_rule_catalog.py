"""Read-only checks for development rule provenance; never evaluates game formulas."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = {"documented", "adaptation", "unresolved"}


class ValidationError(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise ValidationError(message)


def nonempty(value):
    return isinstance(value, str) and bool(value.strip())


def fields(record, names, context):
    require(isinstance(record, dict), f"{context}: expected object")
    for name in names:
        require(name in record, f"{context}: missing {name}")


def local_file(root, value):
    require(nonempty(value), "local path must be a nonempty string")
    path = (root / value).resolve()
    require(not Path(value).is_absolute() and path.is_relative_to(root.resolve()),
            f"local path escapes repository: {value}")
    require(path.is_file(), f"broken local source/reference: {value}")
    return path


def indexed(records, context):
    require(isinstance(records, list), f"{context}: expected list")
    result = {}
    for record in records:
        fields(record, ["id"], context)
        identifier = record["id"]
        require(nonempty(identifier), f"{context}: invalid ID")
        require(identifier not in result, f"{context}: duplicate ID {identifier}")
        result[identifier] = record
    return result


def validate(catalog, fixtures, root=ROOT):
    """Validate supplied objects, allowing tests to mutate copies without writing files."""
    fields(catalog, ["schema_version", "rules"], "catalog")
    fields(fixtures, ["schema_version", "documented", "adaptations"], "fixtures")
    require(catalog["schema_version"] == fixtures["schema_version"] == 1,
            "unsupported schema version")
    rules = indexed(catalog["rules"], "rules")
    require(bool(rules), "empty rule catalog")
    for group in ("documented", "adaptations"):
        require(isinstance(fixtures[group], list), f"fixtures {group}: expected list")
    examples = indexed(fixtures["documented"] + fixtures["adaptations"], "fixtures")
    question_ids = set()
    for identifier, rule in rules.items():
        fields(rule, ["subsystem", "edition_platform", "evidence", "sources", "inputs",
                      "outputs", "behavior", "precision_rounding", "bounds",
                      "trigger_cadence", "update_order", "implementation", "questions",
                      "fixture_ids"], identifier)
        require(re.fullmatch(r"[A-Z]+-\d{3}", identifier), f"{identifier}: invalid rule ID")
        require(rule["evidence"] in EVIDENCE, f"{identifier}: invalid evidence classification")
        for name in ("subsystem", "edition_platform", "behavior", "precision_rounding",
                     "bounds", "trigger_cadence", "update_order"):
            require(nonempty(rule[name]), f"{identifier}: empty {name}")
        for name in ("inputs", "outputs"):
            require(isinstance(rule[name], list) and rule[name], f"{identifier}: empty {name}")
            for quantity in rule[name]:
                fields(quantity, ["name", "unit"], identifier)
                require(nonempty(quantity["name"]) and nonempty(quantity["unit"]),
                        f"{identifier}: empty quantity name/unit")
        questions = indexed(rule["questions"], f"{identifier} questions")
        for question_id, question in questions.items():
            require(question_id not in question_ids, f"duplicate question ID {question_id}")
            question_ids.add(question_id)
            fields(question, ["question", "blocks"], question_id)
            require(nonempty(question["question"]), f"{question_id}: empty question")
            require(isinstance(question["blocks"], list) and question["blocks"] and
                    all(nonempty(story) for story in question["blocks"]),
                    f"{question_id}: missing downstream work")
        if "unknown" in json.dumps({k: rule[k] for k in
                                   ("inputs", "outputs", "precision_rounding", "bounds",
                                    "trigger_cadence", "update_order")}).lower():
            require(bool(questions), f"{identifier}: unknown without follow-up question")
        implementation = rule["implementation"]
        fields(implementation, ["status", "locations", "notes"], identifier)
        require(implementation["status"] in {"not implemented", "partial", "implemented"},
                f"{identifier}: invalid implementation status")
        require(nonempty(implementation["notes"]), f"{identifier}: missing implementation notes")
        require(isinstance(implementation["locations"], list), f"{identifier}: locations must be a list")
        if implementation["status"] != "not implemented":
            require(bool(implementation["locations"]), f"{identifier}: missing implementation location")
        for location in implementation["locations"]:
            local_file(root, location)
        require(isinstance(rule["sources"], list) and rule["sources"], f"{identifier}: missing evidence")
        archived_count = 0
        for source in rule["sources"]:
            fields(source, ["kind", "path", "source_url", "catalog_path", "catalog_file",
                            "sha256", "locator"], identifier)
            require(all(nonempty(source[k]) for k in source), f"{identifier}: empty source field")
            path = local_file(root, source["path"])
            require(source["kind"] in {"archive", "implementation"}, f"{identifier}: invalid source kind")
            if source["kind"] == "archive":
                archived_count += 1
                archive_catalog = local_file(root, source["catalog_path"])
                entries = json.loads(archive_catalog.read_text(encoding="utf-8"))["documents"]
                matches = [entry for entry in entries if entry["file"] == source["catalog_file"]]
                require(len(matches) == 1, f"{identifier}: missing/ambiguous catalog reference")
                entry = matches[0]
                require(path == (archive_catalog.parent / entry["file"]).resolve(),
                        f"{identifier}: catalog source path mismatch")
                require(source["source_url"] == entry["source_url"], f"{identifier}: source URL mismatch")
                actual_hash = hashlib.sha256(path.read_bytes()).hexdigest()
                require(actual_hash == source["sha256"] == entry["sha256"],
                        f"{identifier}: catalog hash mismatch: {source['path']}")
        if rule["evidence"] == "documented":
            require(archived_count > 0, f"{identifier}: documented rule needs archived evidence")
        if rule["evidence"] == "adaptation":
            fields(rule, ["rationale", "adapts"], identifier)
            require(nonempty(rule["rationale"]), f"{identifier}: missing adaptation rationale")
            require(isinstance(rule["adapts"], list) and rule["adapts"], f"{identifier}: missing adapted rule")
            for target in rule["adapts"]:
                require(target in rules and rules[target].get("evidence") == "documented",
                        f"{identifier}: adaptation must link a documented rule")
        require(isinstance(rule["fixture_ids"], list), f"{identifier}: fixture_ids must be a list")
        require(len(set(rule["fixture_ids"])) == len(rule["fixture_ids"]), f"{identifier}: duplicate fixture reference")
        if rule["evidence"] != "unresolved":
            require(bool(rule["fixture_ids"]), f"{identifier}: missing fixture references")
        for fixture_id in rule["fixture_ids"]:
            require(fixture_id in examples and examples[fixture_id].get("rule_id") == identifier,
                    f"{identifier}: broken fixture reference {fixture_id}")
    for group, evidence in (("documented", "documented"), ("adaptations", "adaptation")):
        for example in fixtures[group]:
            identifier = example["id"]
            fields(example, ["rule_id", "evidence", "source_indices", "inputs", "expected",
                             "derivation", "unknowns"], identifier)
            require(example["rule_id"] in rules, f"{identifier}: broken rule reference")
            rule = rules[example["rule_id"]]
            require(example["evidence"] == rule["evidence"] == evidence,
                    f"{identifier}: fixture evidence/group mismatch")
            require(identifier in rule["fixture_ids"], f"{identifier}: missing reciprocal fixture reference")
            require(isinstance(example["source_indices"], list) and example["source_indices"] and
                    all(type(index) is int and 0 <= index < len(rule["sources"])
                        for index in example["source_indices"]), f"{identifier}: broken source reference")
            require(isinstance(example["inputs"], dict) and bool(example["inputs"]) and
                    isinstance(example["expected"], dict) and bool(example["expected"]),
                    f"{identifier}: missing inputs/expected")
            require(nonempty(example["derivation"]), f"{identifier}: missing derivation")
            require(isinstance(example["unknowns"], list) and
                    all(question in {q['id'] for q in rule['questions']}
                        for question in example["unknowns"]), f"{identifier}: broken question reference")
    local_file(root, "data/reference/.gdignore")
    return len(rules), len(examples)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rules", type=Path, default=ROOT / "data/reference/rules.json")
    parser.add_argument("--fixtures", type=Path, default=ROOT / "tests/fixtures/rule_examples.json")
    args = parser.parse_args()
    try:
        counts = validate(json.loads(args.rules.read_text(encoding="utf-8")),
                          json.loads(args.fixtures.read_text(encoding="utf-8")))
    except (ValidationError, OSError, ValueError, KeyError, TypeError) as error:
        print(f"Rule catalog invalid: {error}", file=sys.stderr)
        return 1
    print(f"Rule catalog valid: {counts[0]} rules, {counts[1]} examples; archived hashes match.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

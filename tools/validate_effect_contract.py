"""Read-only S28 provenance and trace validation; no gameplay execution."""
import hashlib
import json
from pathlib import Path
import sys

from validate_rule_catalog import ROOT, indexed, local_file, nonempty, require, ValidationError

ORIGIN_QUESTIONS = {"IDENTITY-Q1", "EVENT-Q1", "EVENT-Q2", "EVENT-Q3", "TIME-Q1", "TIME-Q2"}
CLASSIFICATIONS = {"documented_conditional", "synthetic_conditional", "unresolved", "proposed_adaptation"}


def validate(ledger, fixtures, rules, root=ROOT):
    require(ledger["schema_version"] == fixtures["schema_version"] == 1, "unsupported schema")
    sources = ledger["sources"]
    require(isinstance(sources, dict) and sources, "missing sources")
    archive = json.loads(local_file(root, "assets/documentation/catalog.json").read_text(encoding="utf-8"))
    for source_id, source in sources.items():
        for field in ("path", "source_url", "catalog_file", "sha256", "locator"):
            require(nonempty(source.get(field)), f"{source_id}: missing {field}")
        matches = [d for d in archive["documents"] if d["file"] == source["catalog_file"]]
        require(len(matches) == 1, f"{source_id}: broken catalog reference")
        entry = matches[0]
        require(source["path"] == "assets/documentation/" + entry["file"], "source path mismatch")
        require(source["source_url"] == entry["source_url"], "source URL mismatch")
        digest = hashlib.sha256(local_file(root, source["path"]).read_bytes()).hexdigest()
        require(digest == source["sha256"] == entry["sha256"], "source hash mismatch")
    decisions = indexed(ledger["decisions"], "decisions")
    known_questions = {q["id"] for r in rules["rules"] for q in r["questions"]}
    covered = set()
    for identifier, decision in decisions.items():
        require(decision.get("status") in {"documented", "partially_documented", "unresolved"},
                f"{identifier}: invalid evidence status")
        for field in ("locator", "finding", "unknown", "disposition"):
            require(nonempty(decision.get(field)), f"{identifier}: missing {field}")
        for field, allowed in (("source_refs", set(sources)), ("origin_questions", known_questions),
                               ("blocks", {"S29", "S30", "S31"})):
            refs = decision.get(field)
            require(isinstance(refs, list) and refs and all(x in allowed for x in refs),
                    f"{identifier}: broken {field}")
        covered.update(decision["origin_questions"])
    require(ORIGIN_QUESTIONS <= covered, "missing S01 question coverage")
    for rule in rules["rules"]:
        for question in rule["questions"]:
            if question["id"] not in ORIGIN_QUESTIONS:
                continue
            research = question.get("research", {})
            require(research.get("path") == "data/reference/effect_contract.json", "missing research backlink")
            refs = research.get("decision_ids", [])
            expected = {key for key, d in decisions.items() if question["id"] in d["origin_questions"]}
            require(set(refs) == expected, "broken research decision backlink")
    traces = indexed(fixtures["traces"], "traces")
    classes = set()
    for identifier, trace in traces.items():
        require(trace.get("classification") in CLASSIFICATIONS, f"{identifier}: invalid classification")
        classes.add(trace["classification"])
        refs = trace.get("decision_ids")
        require(isinstance(refs, list) and refs and all(r in decisions for r in refs),
                f"{identifier}: broken decision reference")
        for field in ("preconditions", "steps", "unresolved"):
            value = trace.get(field)
            require(isinstance(value, list) and value and all(nonempty(x) for x in value),
                    f"{identifier}: missing {field}")
        require(isinstance(trace.get("expected"), dict) and trace["expected"], f"{identifier}: missing expected")
        if trace["classification"] == "unresolved":
            require("unknown" in json.dumps(trace["expected"]), f"{identifier}: unresolved trace claims exact outcome")
    require(classes == CLASSIFICATIONS, "missing trace classification coverage")
    return len(decisions), len(traces)


def load():
    return tuple(json.loads((ROOT / path).read_text(encoding="utf-8")) for path in
                 ("data/reference/effect_contract.json", "tests/fixtures/effect_traces.json", "data/reference/rules.json"))


if __name__ == "__main__":
    try:
        decisions, traces = validate(*load())
        print(f"Effect contract valid: {decisions} decisions, {traces} traces; hashes and question links match.")
    except (ValidationError, KeyError, TypeError, ValueError, OSError) as error:
        print(f"Effect contract invalid: {error}", file=sys.stderr)
        sys.exit(1)

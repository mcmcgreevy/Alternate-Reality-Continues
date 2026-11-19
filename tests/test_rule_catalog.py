"""Corrupt in-memory copies to exercise provenance failures without touching archives."""

from copy import deepcopy
import importlib.util
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("validator", ROOT / "tools/validate_rule_catalog.py")
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class RuleCatalogTests(unittest.TestCase):
    def setUp(self):
        self.rules = json.loads((ROOT / "data/reference/rules.json").read_text(encoding="utf-8"))
        self.examples = json.loads((ROOT / "tests/fixtures/rule_examples.json").read_text(encoding="utf-8"))

    def reject(self, message):
        with self.assertRaisesRegex(validator.ValidationError, message):
            validator.validate(self.rules, self.examples)

    def test_valid_seed(self):
        self.assertEqual(validator.validate(self.rules, self.examples), (6, 10))

    def test_duplicate_rule_id(self):
        self.rules["rules"].append(deepcopy(self.rules["rules"][0]))
        self.reject("duplicate ID")

    def test_duplicate_fixture_id(self):
        self.examples["documented"].append(deepcopy(self.examples["documented"][0]))
        self.reject("duplicate ID")

    def test_missing_classification(self):
        del self.rules["rules"][0]["evidence"]
        self.reject("missing evidence")

    def test_missing_evidence(self):
        self.rules["rules"][0]["sources"] = []
        self.reject("missing evidence")

    def test_broken_source(self):
        self.rules["rules"][0]["sources"][0]["path"] = "missing-source.html"
        self.reject("broken local source")

    def test_broken_fixture(self):
        self.rules["rules"][0]["fixture_ids"] = ["MISSING"]
        self.reject("broken fixture reference")

    def test_catalog_hash_mismatch(self):
        self.rules["rules"][0]["sources"][0]["sha256"] = "0" * 64
        self.reject("catalog hash mismatch")

    def test_implementation_cannot_prove_documented_rule(self):
        self.rules["rules"][0]["sources"][0]["kind"] = "implementation"
        self.reject("needs archived evidence")

    def test_adaptation_cannot_enter_documented_fixtures(self):
        self.examples["documented"].append(self.examples["adaptations"].pop())
        self.reject("fixture evidence/group mismatch")

    def test_bad_adaptation_link(self):
        self.rules["rules"][2]["adapts"] = ["MISSING"]
        self.reject("link a documented rule")

    def test_broken_fixture_source(self):
        self.examples["documented"][0]["source_indices"] = [999]
        self.reject("broken source reference")

    def test_unknown_requires_question(self):
        self.rules["rules"][0]["questions"] = []
        self.reject("unknown without follow-up")


if __name__ == "__main__":
    unittest.main()

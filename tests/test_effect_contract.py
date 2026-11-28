"""Validate research provenance failures and independently reviewed trace boundaries."""
from copy import deepcopy
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import validate_effect_contract as contract


class EffectContractTests(unittest.TestCase):
    def setUp(self):
        self.ledger, self.fixtures, self.rules = contract.load()

    def reject(self, message):
        with self.assertRaisesRegex(contract.ValidationError, message):
            contract.validate(self.ledger, self.fixtures, self.rules)

    def test_valid_contract(self):
        self.assertEqual(contract.validate(self.ledger, self.fixtures, self.rules), (13, 13))

    def test_hash_mismatch(self):
        self.ledger['sources']['TECH']['sha256'] = '0' * 64
        self.reject('hash mismatch')

    def test_missing_locator(self):
        del self.ledger['decisions'][0]['locator']
        self.reject('missing locator')

    def test_duplicate_trace(self):
        self.fixtures['traces'].append(deepcopy(self.fixtures['traces'][0]))
        self.reject('duplicate ID')

    def test_broken_decision(self):
        self.fixtures['traces'][0]['decision_ids'] = ['MISSING']
        self.reject('broken decision reference')

    def test_bad_classification(self):
        self.fixtures['traces'][0]['classification'] = 'verified'
        self.reject('invalid classification')

    def test_missing_uncertainty(self):
        self.fixtures['traces'][0]['unresolved'] = []
        self.reject('missing unresolved')

    def test_broken_question_link(self):
        self.ledger['decisions'][0]['origin_questions'] = ['MISSING']
        self.reject('broken origin_questions')

    def test_unresolved_is_not_exact_oracle(self):
        trace = next(t for t in self.fixtures['traces'] if t['id'] == 'ET12')
        trace['expected'] = {'rng_draw_count': 1, 'total_order': ['execute', 'cure']}
        self.reject('claims exact outcome')

    def test_reviewed_fixture_boundaries(self):
        traces = {t['id']: t for t in self.fixtures['traces']}
        self.assertEqual(traces['ET06']['classification'], 'synthetic_conditional')
        self.assertEqual(traces['ET09']['classification'], 'unresolved')
        self.assertEqual(traces['ET11']['classification'], 'proposed_adaptation')
        # Hand-derived from the source table, not production gameplay output.
        self.assertEqual(traces['ET10']['expected']['during_effective'], 18)
        self.assertEqual(traces['ET10']['expected']['during_walking_rate'], 6)
        self.assertEqual(traces['ET10']['expected']['after_walking_rate'], 6)
        self.assertEqual(traces['ET11']['expected']['remaining_game_minutes'], 20)
        self.assertFalse(traces['ET02']['expected']['following_activated'])


if __name__ == '__main__':
    unittest.main()

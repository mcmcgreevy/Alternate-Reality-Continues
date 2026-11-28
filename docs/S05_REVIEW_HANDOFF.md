# S05 research review and correction handoff

Reviewed 2026-11-27. **Review of the identified candidate/current differences is complete with explicit dispositions. S05 itself is not complete.** This is a research handoff, not a claim of complete historical City fidelity or approval to implement every candidate difference.

## Review decision

Proceed only with a separately bounded implementation proposal for three missing doorways and one wall pair. Retain service encodings until their owning systems are integrated. Hold unresolved directional/scenario changes and visual replacements. Do not batch-replace raw codes or make opposite faces reciprocal by assumption.

The [256-row disposition ledger](s05/review-dispositions.csv) gives every identified unequal face its current value, candidate value, evidence reference, player impact and save-policy disposition. All rows are unique and accounted for:

| Disposition | Faces | Decision |
| --- | ---: | --- |
| Proposed bounded geometry corrections | 8 | Three doorways and one wall pair supported by canonical crops plus candidate data. Not implemented. |
| No playable crossing change needed | 4 | Outer faces have no destination cell. No wraparound or new exit proposed. |
| Retain service encodings | 79 | Exact destination-category correspondence established; removing encoding before service integration changes access. |
| Defer visual reconciliation | 135 | Both inspected paths block; candidate artwork distinguishes walls/colonnades. No topology correction established merely from appearance. |
| Hold interaction/direction semantics | 19 | Passable-threshold equality does not establish matching door interactions or scenario exits. |
| Hold original access evidence | 11 | Three Arena directional faces, one unclear ordinary face, seven special-code approaches. |
| **Total** | **256** | No unassigned difference rows. |

These categories intentionally retain uncertainty; “defer” and “hold” are not fidelity passes or cancellation of required work.

## Exact proposed correction set

| Current approached faces | Current → candidate | Proposed purpose |
| --- | --- | --- |
| (10,30) south; (10,31) north | 13 → 3 | Restore first documented doorway. |
| (11,31) east; (12,31) west | 13 → 3 | Restore second documented doorway. |
| (10,32) east; (11,32) west | 13 → 3 | Restore third documented doorway. |
| (26,34) south; (26,35) north | 5 → 13 | Restore documented wall pair. |

The [exact eight-face route analysis](s05/proposed-eight-face-route-review.json) replaces the earlier broader 16-face what-if for this proposal. Under current movement eligibility, with supported doors assumed examinable/openable: start-reachable cells 3267→3287, return-to-tavern cells 3790→3810; no previously reachable or returnable cells are lost. These are graph checks, not original-game execution or a manual playtest. They do not certify UI/service behavior or arbitrary saved states.

## Save and acceptance requirements for the bounded implementation

Preserve positions and unrelated door keys. No cells are removed. Introduce an explicit geometry/save revision policy before writing corrections; older save versions remain readable. Remove only obsolete opened-door keys `city:26,34:2` and `city:26,35:0` as part of that documented migration. New door faces should default closed unless a separately justified migration rule applies; never copy an opposite-side key automatically. Inspect legacy arbitrary keys before finalizing the exact normalization rule.

Acceptance must cover: both directions of all four boundaries; wall rejection despite stale open keys; saves on both sides and old-save migration; all newly accessible cells having expected exits; both tavern cells and south exit; northern City/Dungeon round trip; no new southeast crossing; and source hashes/provenance retained. A focused manual route test follows implementation. Do not claim these checks passed based on the static graph alone.

## Identity and source findings available to implementation

- All 67 legend entries accounted for: 66 observed marker IDs, 463 numbered cells, 73 connected labeled components; Trade Winds explicitly absent. Current 81 location components and 710 perimeter faces inventoried.
- All 4096 candidate map cells and 16384 directed faces compared numerically; 16128 raw equal and 256 unequal. Equality does not establish complete historical runtime semantics.
- Ten category-to-module bindings verified in the candidate. Category, marker, spatial occurrence and shared service-state identity must remain distinct.
- Both Da Place! occurrences share the candidate's friendship, visit frequency/day, refresh hour and six stock words. Keep separate entrance identities; do not default to independent shop state.
- Reused Arena scenario markers do not become healers/guilds merely by marker number. Type0 gate/approach cells use City dispatch; a dormant special-handler marker case is not activation evidence.
- The investigated coordinate registry belongs to ground-item handling, not demonstrated gate triggers.
- Boundary artwork and passability are independent: candidate 6/14 share colonnade artwork but differ in movement blocking.

## What prevents closing the full story

1. **Canonical face coverage remains incomplete.** Both audit ledgers contain 144 examined-but-image-unresolved rows; 16240 retain their prior unverified/uncompared labels. The full numeric candidate comparison does not substitute for this acceptance requirement. Earlier bounded crop findings remain in their reports rather than falsely converting every ledger row to a pass.
2. **Material historical questions remain.** Original interaction and scenario consequences for the 30 held faces, remaining relevant City callbacks and complete treatment of visual distinctions need evidence or an explicit scoped adaptation decision. The eight-face proposal does not answer those questions.
3. **Implementation and migration are not done.** This review changes no game map, service logic or saves.
4. **Acceptance has not run.** The earlier sprint playtest was completed with two reported findings; their fixes await the short retest in [SPRINT_PLAYTEST.md](SPRINT_PLAYTEST.md). That is separate from future S05 correction acceptance.

S05 owns the bounded geography/identity reconciliation and its migration/acceptance. Per-location services remain with S33–S107 and shared systems S15–S21. S05 does not require implementing all 75 location issues. Existing research issues own the inaccessible duplicate/gate investigations; no new hidden stories are created by this report.

## Evidence navigation

- [Location comparison](S05_LOCATION_COMPARISON.md), [current access](S05_LOCATION_ACCESS.md), [candidate map data](S05_ST_MAP_DATA.md).
- [Priority passages](S05_PRIORITY_PASSAGES.md), [special approaches](S05_SPECIAL_PASSAGES.md), [19 other passage differences](S05_PASSABLE_FACE_REVIEW.md).
- [Service identities](S05_SERVICE_IDENTITIES.md), [shared shop state](S05_SHOP_STATE_AND_TRIAGE.md), [category dispatch](S05_CATEGORY_DISPATCH.md), [City helpers](S05_CITY_HELPERS.md).
- [Drawing rules](S05_BOUNDARY_RENDERING.md), [decoded artwork](S05_BOUNDARY_ARTWORK.md), [canonical colonnade limits](S05_COLONNADE_IMAGE_REVIEW.md).

This handoff supersedes earlier progress statements suggesting all raw differences are still untriaged. It does not supersede the canonical Kroah baseline, approved shared-mechanics precedence, or explicitly recorded evidence limitations.

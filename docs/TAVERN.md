# The Tavern: first services pass

Updated 2026-11-09. This replaces the two-gold, full-healing placeholder with a limited food/drink/provisions menu. It is not yet the complete original tavern simulation.

## Evidence

- **Shipped, primary:** the [8-bit survival handbook](https://www.mocagh.org/datasoft/arcity-hintbook8bit-book.pdf), printed page 7 / PDF page 5, identifies free water at The Tavern, Chili as inexpensive nourishment, Pemmican as both nourishment and a carried Food Packet, and consuming Food Packets/Water Flasks while sitting without ordering. The local scan was rendered and visually checked. It also describes buying rounds/friendship and closing-time consequences; those are not implemented here.
- **Shipped, primary manual transcription:** the [C64 guidebook](https://www.lemon64.com/doc/alternate-reality-the-city/49) says taverns provide food, drink and entertainment and change menus hourly. It does not establish the exact item-selection algorithm.
- **Secondary, provisional prices:** Richard Hagenstrom's [Atari 8-bit FAQ, section 3.3 food table](https://gamefaqs.gamespot.com/atari8bit/575500-alternate-reality-the-city/faqs/1531), column Tavern. Its author explicitly warns that some prices are calculated and not every item was observed in every tavern. This implementation uses Chili 8 copper, Pemmican 16, Food Packet 20, Vegetable Soup 4, Sandwich 8, Water Flask 4, and Water 0. These selected values also agree with the later ARX 0.82 tavern data, but that is not independent proof of the original executable.
- **Secondary currency reference:** [C64-Wiki economy section](https://www.c64-wiki.com/wiki/Alternate_Reality_-_The_City) gives 10 copper per silver and 100 per gold. Automatic change-making is our implementation choice.
- **Later remake, provisional effects:** ARX 0.82 src/tavern.cpp supplies the selected hunger/thirst relief amounts. Only these small factual values inform the new implementation; no ARX code is ported. Food healing is not inferred from this evidence.

## Implemented behavior

The menu lists prices before selection. Each item shows its immediate/carried effect and time cost before Y confirms or N cancels. Unaffordable, unavailable, stale-hour and out-of-tavern orders cannot charge coins, add items or advance time. Water works with an empty purse. Food never changes HP. Pemmican feeds the traveller and adds a Food Packet; Packet/Flask purchases add reserves instead of immediately consuming them.

All purchases use the shared character, clock and inventory state. Provisions have separate counts next to equipment in the satchel. Save version 4 includes denominations, needs and reserves. Version 3 imports retain their gold, gain zero silver/copper and reserves, and start fed/refreshed; old equipment is retained, including the existing Bread placeholder. It is not silently converted into a Food Packet. Old prototype-map saves remain incompatible.

## Explicit remake scaffolding

- Two deterministic hourly menus alternate: even hours offer Chili, Pemmican and Food Packets; odd hours offer Soup, Sandwiches and Water Flasks. Free water stays on both. The precise selection and guaranteed availability are not reconstructed original behavior.
- Meals cost 15 minutes; drinks and provision purchases cost one. Sitting costs five minutes. T waits to the next menu hour.
- Starting hunger/thirst are 18/16. Hunger rises by one per clock hour, thirst by one per half hour, capped at 100. A value of 8 or higher displays Hungry/Thirsty. These rates, thresholds and starting values are invented, nonlethal test values.
- While sitting, at most one needed Packet and one needed Flask are consumed per wait action, relieving eight points each. Waiting in the street does not automatically consume them. Exact original consumption timing remains unverified.
- Responses and confirmation wording are newly written. The original full menu, random events, alcoholic drinks, intoxication, rounds/friendship, seating choices, jobs and closing rules are deferred. The placeholder cue and lyrics are unchanged.

## Test this pass

1. At 18:00, open orders with 1. Select Chili, cancel with N: nothing should be spent. Select it again and confirm Y: 8 gold becomes 7 gold / 9 silver / 2 copper, at 18:15. HP remains unchanged.
2. Order Water twice: thirst improves; coins do not change.
3. Order Pemmican: a Food Packet appears. Return with 5 and sit with 4; if Hungry, the packet is consumed. If Fed, it is kept.
4. Open orders and press T: the hour changes and Water Flask replaces Food Packet on the odd-hour menu. Purchase one; its carried count increases.
5. Save, leave, load: coins, needs and provisions should match the save. Continue the Dungeon round trip and confirm those reserves persist.

Automated checks: tests/test_tavern.gd covers exact/insufficient payment, free water, HP, provision effects, hourly/midnight changes, invalid/stale transactions, save migration and invalid-save rejection. tests/test_original_route.gd drives the menu/confirmation/cancel controls and complete trip through the real scene, including graphical captures.

# The Way Back: This Week in Development

**Sprint review: November 16–20, 2026**  
Prepared November 21 from the repository history and acceptance reviews.  
Format: two fictional hosts; Alex asks the player-facing questions, Robin explains the work. The accompanying recording uses synthetic voices. This is a retrospective, not a recording of an actual meeting.

## Opening — a spell that remembers

**Alex:** Welcome to The Way Back: This Week in Development. Tonight we're reviewing the week of November sixteenth through twentieth. And we're starting with a small victory that represents a surprisingly large amount of work. You can give your character a temporary Speed bonus, save the game, load it again, and have the bonus remember exactly how much time it has left.

**Robin:** Which sounds like something a game should simply do. But getting there meant answering a whole chain of questions. What is an effect? Who owns it? When does it run? What happens when two things happen at once? And what, exactly, does loading a saved effect restore?

**Alex:** So the headline is that feature F zero one, the rule and effect model, is complete. But let's make that useful to someone who isn't watching the code. What can Michael actually try now?

**Robin:** In the debug build, press F seven. That activates Physical Speed and reveals the Speed reading. The starting value of thirteen becomes eighteen. The effect lasts thirty game minutes. Save ten minutes into it, load that save, and there are twenty minutes left. Loading doesn't grant the bonus again. Repeating the activation while it's already running doesn't add another five or restart the countdown. At the end, Speed returns to thirteen.

## Chapter one — deciding what we're rebuilding

**Alex:** Before we talk about how that works, there's a decision behind the whole week. Which version of Alternate Reality are we treating as the reference?

**Robin:** For City rules, the baseline is Atari S T, The City, version two, as documented by Kroah. That decision was recorded on November sixteenth. Other editions can help us compare things, but they don't silently replace a documented S T rule. The verified eight-bit Dungeon material remains the Dungeon baseline. Joining those worlds is part of this project's own design.

**Alex:** Why does that distinction matter so much? Couldn't we just choose whichever description seems most reasonable?

**Robin:** We could, but then we'd gradually build a mixture without knowing which decisions came from which game. This week put more discipline around that. Reference documents are preserved locally, their origins are recorded, and research findings are kept separate from the originals. When the evidence leaves a question open, the project records that question. It doesn't turn an assumption into historical fact just because someone wrote code around it.

**Alex:** There was also a very practical project-management lesson. Finishing a story didn't necessarily mean the parent feature was finished.

**Robin:** Right. The reference foundation was valuable, but it wasn't the complete effect system. F zero one needed a concrete finish line: working effect ownership, event handling, timing, and a real character effect surviving save and load. The planning work made those missing pieces visible. That changed the board from a list of loosely related tasks into a sequence with evidence for why each piece was ready.

## Chapter two — research that changed the plan

**Alex:** Some of the week was spent investigating the original program rather than adding visible features. What did that buy us?

**Robin:** It resolved questions that otherwise would have been guesses. The effect research examined isolated original S T routines to understand how records are created, linked, updated and removed. For example, removing an effect record is not automatically the same thing as undoing whatever it did to a stat. Physical Speed has an explicit addition and an explicit subtraction. That distinction matters when effects overlap or arithmetic reaches its limits.

**Alex:** Give me an example of why automatic undo could be wrong.

**Robin:** The supported Speed bonus is a byte-sized value. Adding five to two hundred fifty-three stops at two hundred fifty-five. Subtract five afterward and you get two hundred fifty, not the original two hundred fifty-three. So an engine that assumes every removal should restore an earlier value would be inventing different behavior. The implementation follows the explicit operations we have evidence for.

**Alex:** And timing was significant enough to become a separate research story.

**Robin:** Yes. That was S thirty-two. It investigated timer units, first-update behavior, incubation and the order of simultaneous work. The candidate executable showed a twenty-nine-minute active bonus window for Physical Speed, even though Kroah documents thirty minutes. It also had missed-update behavior that could lose elapsed work. Michael made the explicit call: preserve the documented thirty-minute duration and process all elapsed time reliably. That's a recorded reconstruction choice, not something we're pretending the candidate executable already did.

**Alex:** That's a useful definition of fidelity. Understand the discrepancy, make the decision openly, and leave enough evidence for someone to revisit it.

## Chapter three — one clock, clear stats

**Robin:** With those timing questions settled, two prerequisites became concrete. S zero three delivered the shared calendar and elapsed-time clock. S zero eight delivered the stat model and the supported Speed operations. Together, they gave the effect system a reliable answer to two questions: how much game time passed, and what value should change?

**Alex:** What changed about time from the player's perspective?

**Robin:** A new City journey starts at six in the morning on Sowings twenty-ninth, year zero. Ordinary time runs at fifteen game seconds per real second, so four real seconds equal one game minute. The chapter overview pauses simulation, and losing application focus pauses it too. Returning to the game doesn't suddenly apply a backlog. The map and tavern menus remain live. The calendar follows the documented twelve months of thirty-one days.

**Alex:** And there is support for accelerated services, but that doesn't mean we've built all the inns and guild activities already.

**Robin:** Exactly. The clock provides the interface those services will use. It doesn't manufacture the service gameplay. That distinction appears throughout this review. We can finish a shared capability without claiming every future feature that will depend on it is already playable.

**Alex:** What about the stats? Most players will just see a number on the screen.

**Robin:** Internally, we now distinguish the base stat, its bonuses and penalties, the effective value used by the game, and the value shown to the player. Those are different responsibilities. A fractional base stays fractional even when the effective calculation uses its integer part. Presentation can show a different reading without secretly changing the real stat. That prepares the structure for later content, but it doesn't claim that every delusion, equipment modifier or character-creation rule has been implemented.

**Alex:** There is a slightly counterintuitive playtest detail here: Physical Speed takes thirteen to eighteen, but you shouldn't expect the character to visibly walk faster in this particular example.

**Robin:** Correct. Both values produce a walking rate of six under the documented formula. The effect is real; the walking-rate calculation has steps. That is exactly the kind of thing a good test script should explain before someone reports a perfectly correct result as a bug.

## Chapter four — making effects dependable

**Alex:** Let's connect the remaining stories. What did S twenty-nine and S thirty do?

**Robin:** S twenty-nine established the lifecycle. An effect definition is separate from an active copy. The copy belongs to an owner, and linked records can be managed as a group. Supported events include getting, dropping, using and unusing, with deletion handled as terminal cleanup. The implementation also handles the documented duplicate-suppression behavior. That gave us controlled creation and removal before we started running timers.

**Alex:** Then S thirty made those records run over time.

**Robin:** Yes. It handles initial delays, repeat intervals, finite execution counts, incubation and the supported stat actions. It also settles ordering. Owner events at a particular timestamp run before timers due at that same timestamp. Timers have a stable scheduling order, and a record removed by an earlier action cannot still execute later in that pass.

**Alex:** That sounds like the sort of bug you might only notice after a long play session.

**Robin:** Which is why the tests compare large and small time updates. If seven game minutes pass in one update, the result should agree with the same seven minutes arriving in smaller pieces, given the same event schedule. There are also checks that a rejected update leaves the prior state intact. Unsupported operations and natural-cure definitions are explicitly rejected. We haven't quietly filled those gaps with a default that happens to produce an answer.

## Chapter five — the feature finally closes

**Alex:** S thirty-one was the last piece: taking this out of isolated examples and putting it into the real world and save paths.

**Robin:** That's the important finish. The world now routes elapsed time through the effect system. Physical Speed uses that production path, and the save contains the information needed to resume it: which supported definition it references, which records belong together, and when it expires. Loading reconstructs trusted content without replaying the original grant.

**Alex:** What happens with an older save, or a damaged one?

**Robin:** Older supported saves load with an empty effect set while retaining their character values through the existing migration rules. An old Speed bonus is not treated as proof that a spell must be active. For current saves, an unknown effect reference or malformed effect state causes the load to fail before replacing the live world. The implementation also checks that saving doesn't silently discard unsupported queued work.

**Alex:** And the effect can cross between the City and the Dungeon.

**Robin:** Yes, preserving the shared character effect across chapters is an explicit remake policy. The tests enter the Dungeon, save and restore there, return to the City, and let the same effect expire. That proves the integration policy works. It doesn't claim we have independently established the historical Dungeon version of this spell.

**Alex:** How much verification backs the feature closure?

**Robin:** The final recorded validation includes eighty S thirty-one checks, six hundred thirty-two prerequisite checks, and twenty-three Python provenance tests. Those aren't seven hundred thirty-five different player scenarios; many are focused assertions. There are also tavern, movement, route and Dungeon-floor regressions. The integrated keyboard-handler playtest ran with rendering, and its restored screen was inspected: six ten on the clock, Speed eighteen in the character panel. The publishable code was checked separately from unrelated local edits.

## Closing — what to try, and what comes next

**Alex:** So what should Michael do with the build now?

**Robin:** Use the new manual playtest script. It takes roughly twenty to thirty minutes for the core pass. It covers activation, repeated activation, save and load, pause, expiry, tavern services, controls, weather and the City–Dungeon round trip. It provides expected results and a short problem-report template. The older excursion checklist had stale clock and exit examples, so it now points readers to the current script.

**Alex:** And the local folder has some movement and weather changes that aren't part of the committed feature. That's worth recording when reporting a problem.

**Robin:** It is. A clean checkout of the completed build and the current working folder are not identical. The script calls out that distinction. We should preserve the work without presenting it as part of a reviewed release simply because it's visible on this machine.

**Alex:** Looking ahead, what has this week made possible?

**Robin:** Later item, spell and survival work now has a tested foundation for ownership, timing, stat changes and persistence. The next sprint still needs its own priorities and readiness review. Full combat, guild acquisition, most other shops, deeper Dungeon floors and complete survival rules remain outside this feature. My recommendation is to use the manual playtest first, collect the concrete failures and confusing moments, and choose the next story with that evidence in hand. That's a recommendation, not an already approved sprint commitment.

**Alex:** The result this week is a feature we can explain, test and close. A temporary spell remembers its remaining life. The clock and character agree about what happened. And the project has a clearer boundary between what is documented, what was deliberately adapted, and what is still waiting.

**Robin:** F zero one is done. The rest of the game has somewhere sound to build from.

**Alex:** That's this week's review of The Way Back. Next time you press F seven, there's quite a bit of history, research and testing behind that little change from thirteen to eighteen. Thanks for listening.

## Show notes and evidence — not spoken

- Weekly history: commits `278a430` through `8bdfed2`; most implementation commits are dated November 19–20. The City source-baseline decision was recorded November 16. This episode does not claim every existing visual, music or map feature was created this week.
- [Canonical source baseline](SOURCE_BASELINE.md)
- [F01 feature acceptance](F01_ACCEPTANCE_REVIEW.md) and [feature plan](F01_RULE_EFFECT_PLAN.md)
- [S29 acceptance](S29_ACCEPTANCE_REVIEW.md) and [original-code research](S29_ST_EFFECT_RESEARCH.md)
- [S32 timing evidence and approved reconciliation](S32_ST_TIMING_RESEARCH.md)
- [S03 clock/calendar](S03_CLOCK.md) and [S08 stats](S08_STATS.md)
- [S30 timing acceptance](S30_ACCEPTANCE_REVIEW.md)
- [S31 persistence, migration and integrated playtest](S31_ACCEPTANCE_REVIEW.md)
- [Current manual playtest](LATEST_BUILD_PLAYTEST.md)
- Completed feature code: `e9b2c94`; manual script: `8bdfed2`. Local uncommitted movement/weather changes are excluded from the completion claim.
- Synthetic narration uses locally installed Windows voices. No voice cloning, original-game music or external audio service is used.

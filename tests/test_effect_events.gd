extends SceneTree

const Definitions = preload("res://scripts/effect_definitions.gd")
const Events = preload("res://scripts/effect_events.gd")
var checks := 0
var failures := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func definition(identifier: String, guarded: bool, parameter: int = 5) -> Dictionary:
	return {"definition_id": identifier, "definition_revision": 1, "disallow_multiple": guarded,
		"comparison": {"effect_type": 3, "interval_raw": 1, "natural_cure_raw": 0,
			"action_raw": 129, "target_offset_raw": 6318, "block_count_raw": 1,
			"block_gap_raw": 0, "parameter_raw": parameter}}

func listener(identifier: String, mask: int, linked: bool = false) -> Dictionary:
	return {"definition_id": identifier, "required_events": mask, "link_to_previous": linked}

func send(runtime: RefCounted, owner: String, mask: int) -> Dictionary:
	check(runtime.queue_events(owner, mask).ok, "queue supported events")
	return runtime.dispatch_pending(owner)

func _initialize() -> void:
	var definitions = Definitions.new()
	for candidate in [definition("use", false), definition("unuse", true), definition("extra", false, 6)]:
		check(definitions.register_definition(candidate).ok, "register definition")
	var runtime = Events.new(definitions)
	var listeners := [listener("use", Events.USE), listener("extra", Events.USE, true),
		listener("unuse", Events.UNUSE)]
	check(runtime.register_entity("a", listeners).ok, "register generic owner")
	listeners[0].required_events = Events.UNUSE
	check(runtime.entity_snapshot("a").entity.listeners[0].required_events == Events.USE, "input listeners copied")
	var snapshot: Dictionary = runtime.entity_snapshot("a").entity
	snapshot.pending_events = Events.USE
	check(runtime.entity_snapshot("a").entity.pending_events == 0, "entity snapshot isolated")
	check(not runtime.register_entity("a", []).ok, "duplicate owner rejected")
	check(runtime.dispatch_pending("a").events.is_empty(), "empty pending mask is no-op")
	var used: Dictionary = send(runtime, "a", Events.USE)
	check(used.events.size() == 1 and used.events[0].created_ids.size() == 2, "activate only matching listeners")
	check(runtime.active_snapshot()[0].group_id == runtime.active_snapshot()[1].group_id, "linked matching listeners share group")
	check(runtime.entity_snapshot("a").entity.pending_events == 0, "handled events clear")
	var repeated: Dictionary = send(runtime, "a", Events.USE)
	check(repeated.events[0].created_ids.size() == 2 and runtime.active_snapshot().size() == 4, "H-off repeat creates fresh group")
	var unused: Dictionary = send(runtime, "a", Events.UNUSE)
	check(unused.events[0].removed_ids.size() == 4, "opposition removes both earlier Use groups")
	check(unused.events[0].created_ids.size() == 1, "remove opposition before global H check on equal contents")
	check(runtime.active_snapshot()[0].definition.definition_id == "unuse", "only Unuse effect remains")
	var again: Dictionary = send(runtime, "a", Events.UNUSE)
	check(again.events[0].removed_ids.is_empty() and again.events[0].created_ids.is_empty(), "repeat H-on Unuse does not duplicate")
	check(again.events[0].suppressed_at == 0, "repeat suppression reported")
	check(runtime.register_entity("b", [listener("extra", Events.USE)]).ok, "register another owner")
	send(runtime, "b", Events.USE)
	var before: Array = runtime.active_snapshot()
	check(runtime.queue_events("a", Events.USE).ok, "queue pending before invalid input")
	for invalid_mask in [0, -1, 1, 2, 16, 32, 64, 128, Events.USE | 16]:
		check(not runtime.queue_events("a", invalid_mask).ok, "unsupported mask rejected")
	check(runtime.entity_snapshot("a").entity.pending_events == Events.USE, "failed queue preserves pending work")
	check(runtime.active_snapshot() == before, "failed queue leaves active records unchanged")
	check(not runtime.queue_events("missing", Events.USE).ok and not runtime.dispatch_pending("missing").ok, "unknown owner fails explicitly")
	var combined: Dictionary = send(runtime, "a", Events.UNUSE)
	check(combined.events.size() == 2 and combined.events[0].event == Events.USE
		and combined.events[1].event == Events.UNUSE, "coincident events run Use then Unuse")
	check(combined.events[1].removed_ids == combined.events[0].created_ids, "later opposition removes newly activated earlier group")
	var b_survives := false
	for instance in runtime.active_snapshot():
		if instance.owner_id == "b":
			b_survives = true
	check(b_survives, "dispatch never removes another owner's group")
	for invalid_listener in [listener("missing", Events.USE), listener("use", 16),
		listener("use", Events.USE).merged({"special_use": true}), {}, null]:
		check(not runtime.register_entity("bad", [listener("use", Events.USE), invalid_listener]).ok,
			"invalid trailing listener rejects entire registration")
		check(not runtime.entity_snapshot("bad").ok, "failed registration creates no owner")
	check(runtime.register_entity("empty", []).ok, "owner may have no listeners")
	check(send(runtime, "empty", Events.USE).events[0].created_ids.is_empty(), "empty owner handles event without effects")
	var shared = Events.new(definitions)
	check(shared.register_entity("shared", [listener("use", Events.USE | Events.UNUSE)]).ok, "listener may match both supported bits")
	var one: Dictionary = send(shared, "shared", Events.USE)
	var two: Dictionary = send(shared, "shared", Events.USE)
	check(two.events[0].removed_ids == one.events[0].created_ids, "opposition uses listener mask, not merely activation event")
	check(shared.active_snapshot().size() == 1, "shared-mask replacement does not leak old record")
	var filtered = Events.new(definitions)
	filtered.register_entity("filtered", [listener("extra", Events.UNUSE), listener("use", Events.USE, true)])
	send(filtered, "filtered", Events.USE)
	check(filtered.active_snapshot()[0].instance_id == filtered.active_snapshot()[0].group_id,
		"skipped non-listener does not become linked predecessor")
	print("Effect event dispatch: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

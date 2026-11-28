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
	for invalid_mask in [0, -1, 32, 64, 128, Events.USE | 32, 4.0, "4", true]:
		check(not runtime.queue_events("a", invalid_mask).ok, "unsupported mask rejected")
	check(runtime.entity_snapshot("a").entity.pending_events == Events.USE, "failed queue preserves pending work")
	check(runtime.active_snapshot() == before, "failed queue leaves active records unchanged")
	for invalid_held in [0, "false", null]:
		check(not runtime.register_entity("invalid-held", [], invalid_held).ok, "held state cannot be coerced")
		check(not runtime.entity_snapshot("invalid-held").ok, "invalid held state creates no owner")
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
	var possession = Events.new(definitions)
	check(possession.register_entity("item", [listener("use", Events.GET), listener("extra", Events.DROP)]).ok,
		"register Get/Drop listeners")
	check(send(possession, "item", Events.DROP).events[0].skipped, "Drop while unheld is skipped")
	check(not possession.entity_snapshot("item").entity.held, "skipped Drop preserves held state")
	var acquired: Dictionary = send(possession, "item", Events.GET)
	check(possession.entity_snapshot("item").entity.held and acquired.events[0].created_ids.size() == 1, "Get holds owner and activates")
	var dropped: Dictionary = send(possession, "item", Events.DROP)
	check(dropped.events[0].removed_ids == acquired.events[0].created_ids, "Drop removes Get group")
	check(not possession.entity_snapshot("item").entity.held and dropped.events[0].created_ids.size() == 1, "Drop releases and activates")
	var repeated_drop: Dictionary = send(possession, "item", Events.DROP)
	check(repeated_drop.events[0].skipped and possession.active_snapshot().size() == 1, "repeat Drop does not re-activate")
	var reacquired: Dictionary = send(possession, "item", Events.GET)
	check(reacquired.events[0].removed_ids == dropped.events[0].created_ids, "Get removes prior Drop group")
	check(possession.register_entity("other", [listener("extra", Events.USE)], true).ok, "explicit initially held owner supported")
	send(possession, "other", Events.USE)
	var deleted: Dictionary = send(possession, "item", Events.DELETE)
	check(deleted.events[0].removed_ids == reacquired.events[0].created_ids, "Delete removes owner's remaining records")
	check(deleted.events[0].created_ids.is_empty(), "Delete never activates listeners")
	check(possession.entity_snapshot("item").entity.deleted and not possession.entity_snapshot("item").entity.held,
		"Delete leaves inert owner tombstone")
	check(possession.active_snapshot().size() == 1 and possession.active_snapshot()[0].owner_id == "other", "Delete preserves other owner")
	check(send(possession, "item", Events.DELETE).events.is_empty(), "repeat Delete is idempotent")
	check(not possession.queue_events("item", Events.USE).ok, "deleted owner cannot receive fresh work")
	check(not possession.register_entity("item", []).ok, "deleted owner ID cannot be reused")
	var all_events = Events.new(definitions)
	all_events.register_entity("all", [listener("use", Events.GET), listener("extra", Events.DROP),
		listener("use", Events.USE), listener("extra", Events.UNUSE)])
	var all_result: Dictionary = send(all_events, "all", Events.SUPPORTED_EVENTS)
	var event_order: Array = []
	for event in all_result.events:
		event_order.append(event.event)
	check(event_order == [1, 2, 4, 8, 16], "full supported order ends in Delete")
	check(all_events.active_snapshot().is_empty(), "combined events leave no records after Delete")
	check(all_events.entity_snapshot("all").entity.pending_events == 0, "combined events cleared")
	_run_lifecycle_traces(definitions)
	print("Effect event dispatch: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _run_lifecycle_traces(definitions: RefCounted) -> void:
	var fixture = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/effect_lifecycle_traces.json"))
	check(fixture != null and fixture.schema_version == 1, "load reviewed S29 trace fixtures")
	for trace in fixture.cases:
		var runtime = Events.new(definitions)
		for owner in trace.owners:
			# JSON numbers are floats in Godot; convert only the fixture's known
			# integer mask field. The public API itself still rejects malformed data.
			var bindings: Array = owner.listeners.duplicate(true)
			for binding in bindings:
				binding.required_events = int(binding.required_events)
			check(runtime.register_entity(owner.owner_id, bindings).ok, trace.id + " register owner")
		for step in trace.steps:
			check(runtime.queue_events(step.owner_id, int(step.event_mask)).ok, trace.id + " queue")
			check(runtime.dispatch_pending(step.owner_id).ok, trace.id + " dispatch")
			var active: Array = []
			var groups: Dictionary = {}
			for instance in runtime.active_snapshot():
				active.append(instance.owner_id + ":" + instance.definition.definition_id)
				groups[instance.group_id] = true
			check(active == step.expected_active, trace.id + " active copies")
			check(groups.size() == int(step.expected_groups), trace.id + " independent groups")
			var entity: Dictionary = runtime.entity_snapshot(step.owner_id).entity
			check(entity.held == step.expected_held and entity.deleted == step.expected_deleted,
				trace.id + " owner state")
			check(entity.pending_events == 0, trace.id + " cleared pending events")

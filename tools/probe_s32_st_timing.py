"""Probe unchanged ST clock/scheduler fragments, not a full Atari emulation.

Run extract_s29_st_evidence.py first; use tools/reference/s29-python on
PYTHONPATH (Unicorn 2.1.4). End addresses are observation boundaries, not
patched instructions. We supply synthetic RAM and omit unrelated subsystems.
"""
import hashlib
import json

from probe_s29_st_effects import (
    Probe, ROOT, DIRECTORY, CODE, GLOBAL, ACTIVE, STOP, SPEED_BONUS,
    effect, synthetic_entity, registers,
)


class TimingProbe(Probe):
    def write(self, offset, value, width=1):
        self.cpu.mem_write(GLOBAL + offset, value.to_bytes(width, 'big'))

    def read(self, offset, width=1):
        return int.from_bytes(self.cpu.mem_read(GLOBAL + offset, width), 'big')

    def fragment(self, start, end, **values):
        self.set_register('A7', 0xff000)
        for name, value in values.items():
            self.set_register(name, value)
        self.cpu.emu_start(CODE + start, CODE + end, count=100000)
        assert self.cpu.reg_read(registers.UC_M68K_REG_PC) == CODE + end

    def clock_interrupt(self):
        # The original clock chains to a previous interrupt handler. Stop at
        # that boundary; do not pretend to execute the OS/other handler.
        self.write(-0x41f2, STOP, 4)
        self.call(0x163c)

    def scheduler(self):
        # Includes pause gate, changed-clock gate, owner events, then timers.
        # Stops before metabolism/weather. No engine routines are stubbed.
        if self.read(-0x41ed):
            stop_offset = 0x3cc
        elif self.read(0x2bc, 4) == self.read(-0x422e, 4):
            stop_offset = 0x3b6
        else:
            stop_offset = 0x3aa
        self.fragment(0x38e, stop_offset)

    def heartbeat(self):
        self.clock_interrupt()
        self.scheduler()
        return self.read(0x18ae)


def record(timer=1, interval=1, counter=1, action=0x81, group=0xff,
           incubating=False):
    data = bytearray(effect(link=group))
    data[0] |= 0x40 if incubating else 0
    data[3] = counter
    data[4:6] = timer.to_bytes(2, 'big')
    data[6:8] = interval.to_bytes(2, 'big')
    data[9] = action
    return bytes(data)


def prepared(*records):
    probe = TimingProbe(synthetic_entity(*records))
    probe.activate()
    probe.write(0xf0e, 240, 2)
    probe.write(0xf2a, 240)
    return probe


def main():
    results = {}
    probe = prepared(record(counter=0))
    assert [probe.heartbeat() for _ in range(239)] == [0] * 239
    assert probe.read(0x1826) == 0
    assert probe.heartbeat() == 5 and probe.read(0x1826) == 1
    assert [probe.heartbeat() for _ in range(240)][-1] == 10
    assert probe.read(0x1826) == 2
    results['ordinary_cadence'] = dict(interrupts_per_calendar_minute=240,
        scheduler_calls_per_effect_update=240, bonuses_at_240_480=[5, 10])

    probe = prepared(record(counter=0))
    probe.write(0x1801, 255)
    assert [probe.heartbeat() for _ in range(3)] == [5, 10, 15]
    assert probe.read(0x1826) == 3
    results['accelerated_cadence'] = dict(calendar_minutes_per_interrupt=1,
        effect_updates_per_observed_interrupt=1, bonus_after_three=15)

    probe = prepared(record(counter=0))
    probe.write(-0x41ed, 255)
    for _ in range(300):
        probe.heartbeat()
    assert probe.read(0x1826) == 0 and probe.read(0xf0e, 2) == 240
    probe.write(-0x41ed, 0)
    probe.scheduler()
    assert probe.read(0xf0e, 2) == 239
    results['pause'] = dict(paused_interrupts=300, calendar_minutes=0,
        effect_countdown_after_resume_poll=239,
        limitation='Resume observes one changed counter; not a backlog of 300 updates.')

    probe = prepared(record(counter=0))
    for _ in range(480):
        probe.clock_interrupt()
    probe.scheduler()
    assert probe.read(0x1826) == 2 and probe.read(0xf0e, 2) == 239
    probe.scheduler()
    assert probe.read(0xf0e, 2) == 239
    results['missed_polls'] = dict(interrupts=480, calendar_minutes=2,
        effect_countdown=239, duplicate_poll_no_work=True,
        discrepancy='The caller compares counters for inequality, not elapsed delta.')

    for name, data, expected in [
        ('initial_zero', record(timer=0), [0, 0, 0]),
        ('interval_zero', record(interval=0, counter=0), [5, 5, 5]),
        ('finite_counter', record(counter=2), [5, 10, 10]),
        ('zero_counter', record(counter=0), [5, 10, 15]),
        ('incubation_action', record(incubating=True, counter=0), [5, 10, 15]),
    ]:
        probe = prepared(data)
        observed = [probe.tick() for _ in range(3)]
        assert observed == expected
        results[name] = dict(bonus_by_forced_update=observed,
            live_slots=probe.live(), first_slot_hex=probe.slot(0).hex())

    # Slot order is observable because saturating Add/Sub do not commute.
    for name, first, second, expected in [
        ('add_then_subtract', 0x81, 0x91, 250),
        ('subtract_then_add', 0x91, 0x81, 253),
    ]:
        probe = prepared(record(action=first), record(action=second))
        probe.write(0x18ae, 253)
        assert probe.tick() == expected
        results[name] = dict(initial_bonus=253, final_bonus=expected)

    probe = prepared(record(), record(group=0, action=0x91))
    assert probe.tick() == 5 and probe.live() == []
    results['root_removes_later_due_child'] = dict(bonus=5, live_slots=[],
        child_action_executed=False)

    # Entity table offsets are relative to the table base, not each entry.
    # Higher owner slots dispatch first, allocating lower effect slots first.
    probe = prepared()
    for owner_slot, entity_offset, action in [(1, 0x2800, 0x91), (2, 0x2900, 0x81)]:
        entity = bytearray(synthetic_entity(record(action=action)))
        entity[2] = 4
        probe.cpu.mem_write(GLOBAL + entity_offset, bytes(entity))
        probe.write(0x227e + 2 * owner_slot, entity_offset - 0x227e, 2)
    probe.write(0xf0e, 1, 2)
    probe.write(0x18ae, 253)
    assert probe.heartbeat() == 250
    assert probe.read(0x2802) == 0 and probe.read(0x2902) == 0
    assert probe.live() == []
    results['owner_events_before_due_timers'] = dict(owner_order=[2, 1],
        actions=['Add 5', 'Subtract 5'], initial_bonus=253, final_bonus=250,
        newly_activated_effects_execute_same_pass=True)

    probe = prepared(record(counter=0))
    entity = bytearray(synthetic_entity(record(counter=0)))
    entity[2] = 16  # Delete pending on a synthetic explicitly bound owner.
    entity[6 + 15] = 0
    probe.cpu.mem_write(GLOBAL + 0x2800, bytes(entity))
    probe.write(0x2280, 0x2800 - 0x227e, 2)
    probe.write(0x1922, GLOBAL + 0x2800 + len(entity), 4)
    probe.cpu.mem_write(GLOBAL + 0x18ee, b'\xff' * 10)
    probe.write(0xf0e, 1, 2)
    assert probe.heartbeat() == 0 and probe.live() == []
    results['delete_before_due_timer'] = dict(bonus=0, live_slots=[],
        limitation='Synthetic explicit template group binding; does not resolve historical binding creation.')

    probe = prepared(record(timer=65535, interval=65535, counter=255))
    assert probe.tick() == 0
    assert int.from_bytes(probe.slot(0)[4:6], 'big') == 65534
    results['unsigned_timer_word'] = dict(initial=65535, after_update=65534,
        counter_unchanged=probe.slot(0)[3])

    # Text uses a short one-slot record. Root first expiry enables linked text;
    # counter exhaustion may immediately remove it in that same updater pass.
    for counter in [0, 1]:
        probe = prepared(record(incubating=True, counter=counter))
        probe.cpu.mem_write(ACTIVE + 16, bytes([0xe0, 0]) + b'\0' * 14)
        assert probe.tick() == 5
        assert probe.slot(1)[0] == (0xe8 if counter == 0 else 0x80)
        results[f'incubation_text_counter_{counter}'] = dict(
            action_executed=True, text_marker=probe.slot(1)[0], live_slots=probe.live())

    guild = (DIRECTORY / 'module-15.bin').read_bytes()
    assert hashlib.sha256(guild).hexdigest() == '6c2c2738fe15eb862f92adf6df7c65da95d877a81a4a78d71c883aabdb8b8cbb'
    physical_speed = guild[0x2a0e:0x2a69]
    probe = TimingProbe(physical_speed)
    probe.activate()
    probe.write(0xf2a, 240)
    # Execute the actual successful-cast pending-Use/countdown-reset fragment.
    probe.fragment(0xb86, 0xb92, A0=0x50000)
    transitions = []
    previous = 0
    for heartbeat in range(1, 6962):
        bonus = probe.heartbeat()
        if bonus != previous:
            transitions.append([heartbeat, bonus])
            previous = bonus
    assert transitions == [[1, 5], [6961, 0]]
    results['physical_speed_cast_phase'] = dict(transitions_by_observed_interrupt=transitions,
        duration_between_add_subtract_calendar_minute_periods=29,
        limitation='Activation helper plus successful-cast reset fragment; not full spell UI/RNG.')

    output = dict(evidence='Unchanged module-05 fragments and synthetic RAM; not full ST emulation',
        module_05_sha256=hashlib.sha256((DIRECTORY / 'module-05.bin').read_bytes()).hexdigest(),
        emulator='Unicorn 2.1.4, M68000', scenarios=results)
    path = DIRECTORY / 's32-timing-probe-results.json'
    path.write_text(json.dumps(output, indent=2) + '\n', encoding='utf-8')
    print(f'{len(results)} S32 original-code scenarios passed; results: {path}')


if __name__ == '__main__':
    main()

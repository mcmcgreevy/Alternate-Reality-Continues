"""Execute isolated candidate ST routines with Unicorn 2.1.4 (M68000).

Run extract_s29_st_evidence.py first. This is a research harness, not a game
emulator or replacement implementation. No OS/engine calls are stubbed to pass.
Forced effect-update calls do not establish the original scheduler's time unit.
"""
import hashlib
import json
from pathlib import Path

from unicorn import Uc, UC_ARCH_M68K, UC_MODE_BIG_ENDIAN
from unicorn import m68k_const as registers

ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = ROOT / 'tools/reference/s29-verified'
CODE = 0x10000
GLOBAL = 0x70000
ENTITY = 0x50000
ACTIVE = GLOBAL + 0x1c7e
STOP = 0x90000
SPEED_BONUS = GLOBAL + 0x18ae


class Probe:
    def __init__(self, entity):
        code = (DIRECTORY / 'module-05.bin').read_bytes()
        assert hashlib.sha256(code).hexdigest() == '8dcd198113217567d412f50af3ce7b2dd33a8981d14a8cde5b8545b319e56190'
        self.cpu = Uc(UC_ARCH_M68K, UC_MODE_BIG_ENDIAN)
        self.cpu.ctl_set_cpu_model(registers.UC_CPU_M68K_M68000)
        self.cpu.mem_map(0, 0x100000)
        self.cpu.mem_write(CODE, code)
        self.cpu.mem_write(ENTITY, entity)
        self.entity = entity
        self.set_register('SR', 0x2700)
        self.set_register('A5', GLOBAL)
        self.cpu.mem_write(GLOBAL - 0x4264, b'\x00\x02')  # Synthetic owner slot.
        for index in range(96):
            self.cpu.mem_write(ACTIVE + index * 16, b'\x80')

    def set_register(self, name, value):
        self.cpu.reg_write(getattr(registers, 'UC_M68K_REG_' + name), value)

    def call(self, offset, **values):
        self.set_register('A7', 0xff000)
        self.cpu.mem_write(0xff000, STOP.to_bytes(4, 'big'))
        for name, value in values.items():
            self.set_register(name, value)
        self.cpu.emu_start(CODE + offset, STOP, count=100000)
        assert self.cpu.reg_read(registers.UC_M68K_REG_PC) == STOP, 'Routine did not return'

    def slot(self, index):
        return bytes(self.cpu.mem_read(ACTIVE + index * 16, 16))

    def live(self):
        return [index for index in range(96) if self.slot(index)[0] >= 0x81]

    def activate(self):
        self.call(0x29e8, A0=ENTITY, D0=4)

    def tick(self):
        self.cpu.mem_write(GLOBAL + 0x1801, b'\x01')  # Force one update, bypass cadence.
        self.call(0x2434)
        return self.cpu.mem_read(SPEED_BONUS, 1)[0]

    def remove_group(self, group):
        self.call(0x25c8, D0=group)


def synthetic_entity(*effects):
    return bytes([0x81, 7 + 16 * len(effects), 0, 0, 0, 6]) + b''.join(effects) + b'\0'


def effect(link=0xff, event=4, parameter=5):
    return bytes([0x83, link, event, 1, 0, 1, 0, 1, 0, 0x81, 0x18, 0xae, 1, 0, parameter, 0xff])


def main():
    # The literal entity anchors its identity and all bytes, including text padding.
    guild = (DIRECTORY / 'module-15.bin').read_bytes()
    assert hashlib.sha256(guild).hexdigest() == '6c2c2738fe15eb862f92adf6df7c65da95d877a81a4a78d71c883aabdb8b8cbb'
    physical_speed = guild[0x2a0e:0x2a69]
    assert physical_speed[:21] == bytes.fromhex('815b00000015') + b'Physical Speed\0'
    assert physical_speed[21:37].hex() == '83ff8401001e0000009118ae010005ff'
    assert physical_speed[69:85].hex() == '83ff840100010001008118ae010005ff'
    results = {}

    probe = Probe(physical_speed)
    probe.activate()
    assert probe.live() == [0, 1, 3]
    assert [probe.slot(i)[1] for i in [0, 1, 3]] == [0, 0, 3]
    assert bytes(probe.cpu.mem_read(ENTITY, len(physical_speed))) == physical_speed
    results['physical_speed_activation'] = dict(live_slots=[0, 1, 3], groups=[0, 0, 3], template_unchanged=True)
    bonus = [probe.tick() for _ in range(30)]
    assert bonus == [5] * 29 + [0]
    assert probe.live() == []
    results['physical_speed_expiry'] = dict(bonus_by_forced_update=bonus, live_slots_at_end=[])

    probe = Probe(physical_speed)
    probe.activate()
    assert probe.tick() == 5
    probe.remove_group(0)
    assert probe.live() == []
    assert probe.tick() == 5
    probe.remove_group(0)
    assert probe.tick() == 5
    results['early_group_removal'] = dict(bonus_after_repeated_removal=5, live_slots=[])

    probe = Probe(physical_speed)
    probe.activate()
    probe.activate()
    assert probe.live() == [0, 1, 3]
    results['repeat_physical_speed_before_update'] = dict(live_slots=[0, 1, 3], duplicated=False)

    probe = Probe(synthetic_entity(effect(link=0), effect(link=0)))
    probe.activate()
    assert probe.live() == [0, 1]
    assert probe.slot(0)[1] == probe.slot(1)[1] == 0
    results['first_zero_link'] = dict(live_slots=[0, 1], groups=[0, 0])

    probe = Probe(synthetic_entity(effect(), effect(link=0)))
    probe.activate()
    probe.activate()
    assert probe.live() == [0, 1, 2, 3]
    assert [probe.slot(i)[1] for i in range(4)] == [0, 0, 2, 2]
    probe.remove_group(0)
    assert probe.live() == [2, 3]
    results['h_off_repeat_and_scoped_removal'] = dict(groups_before=[0, 0, 2, 2], live_after_remove_group_zero=[2, 3])

    probe = Probe(synthetic_entity(effect(event=1), effect(link=0)))
    probe.activate()
    assert probe.live() == [0] and probe.slot(0)[1] == 0
    results['skipped_predecessor_zero_link'] = dict(live_slots=[0], groups=[0])

    # This deliberately calls the original opposing-removal helper, NOT a
    # reconstruction. It shows why template-byte-15 lifetime needs investigation.
    probe = Probe(synthetic_entity(effect()))
    probe.activate()
    probe.call(0x2a8c, A0=ENTITY, D0=4)
    assert probe.live() == [0]
    results['opposing_helper_with_unchanged_template'] = dict(live_slots=[0], template_group_byte=255,
        limitation='Isolated path: does not prove all game callers leave template byte 15 unchanged.')

    probe = Probe(synthetic_entity(effect(event=1, parameter=6), effect(event=0x84)))
    probe.cpu.mem_write(ACTIVE, effect())  # Active record equals second, not first, definition.
    probe.activate()
    assert probe.live() == [0, 1]
    results['h_after_skipped_definition'] = dict(live_slots=[0, 1],
        discrepancy='Candidate compares stale a0 (non-listener), allowing a duplicate of the second definition.')

    probe = Probe(synthetic_entity(effect(parameter=5)))
    probe.cpu.mem_write(SPEED_BONUS, b'\xfd')
    probe.activate()
    assert probe.tick() == 255
    subtract = bytearray(effect(parameter=5)); subtract[9] = 0x91
    probe = Probe(synthetic_entity(bytes(subtract)))
    probe.cpu.mem_write(SPEED_BONUS, b'\x02')
    probe.activate()
    assert probe.tick() == 0
    results['one_byte_arithmetic'] = dict(add_253_and_5=255, subtract_5_from_2=0)

    smithy = (DIRECTORY / 'module-12.bin').read_bytes()
    assert hashlib.sha256(smithy).hexdigest() == 'dab9bea9b00c97f1b64522bab8ff371e83f5e5a68ca33bfb5d98c624d2fae392'
    for name, offset in [('Dagger', 0x86d), ('Leather Helmet', 0xa05)]:
        equipment = smithy[offset:offset + smithy[offset + 1]]
        assert equipment[6:].split(b'\0')[0].decode('ascii') == name
        assert equipment[equipment[5]] == 0  # Terminator: no attached effects.
        probe = Probe(equipment)
        for event_mask in [1, 2, 4, 8]:
            probe.call(0x29e8, A0=ENTITY, D0=event_mask)
        assert probe.live() == []
        results['ordinary_equipment_' + name.lower().replace(' ', '_')] = dict(
            module=12, offset=offset, effect_records=0, live_slots=[],
            limitation='Activation helper only; does not settle enchanted equipment or dispatcher bookkeeping.')

    output = dict(evidence='Isolated original-code execution with synthetic RAM; not full ST emulation',
                  emulator='Unicorn 2.1.4, M68000', scheduler='forced update calls; no game-time mapping',
                  scenarios=results)
    (DIRECTORY / 'effect-probe-results.json').write_text(json.dumps(output, indent=2) + '\n', encoding='utf-8')
    print(f'{len(results)} original-code scenarios passed; results: {DIRECTORY / "effect-probe-results.json"}')


if __name__ == '__main__':
    main()

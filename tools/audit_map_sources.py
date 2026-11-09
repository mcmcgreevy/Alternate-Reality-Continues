"""Inventory a local ardungeon checkout without guessing map semantics.

Usage: python tools/audit_map_sources.py PATH_TO_PINNED_ARDUNGEON
Outputs hashes and evidence locations, not original game data or playable maps.
"""
import argparse
import hashlib
import json
from pathlib import Path

REVISION = "823aaf1bc3b797070cbb0f79223a06b02491e792"
SEGMENTS = ["21-s011.asm", "21-s052.asm", "21-s093.asm", "21-s134.asm",
            "21-s175.asm", "21-s216.asm", "21-s257.asm"]
ANCHORS = {
    "11-s002.asm": ["; map 1", "; map 7"],
    "11-s205.asm": ["loc_F900:", "loc_F953:"],
    "11-s517.asm": ["loc_318C:", "unk_3225:", "sub_3531:",
                    "byte_3B24:", "byte_3B34:", "unk_3B64:", "unk_3B6C:"],
}


def audit(root: Path) -> dict:
    result = {"repository": "https://github.com/jduerstock/ardungeon",
              "expected_revision": REVISION,
              "status": "source inventory only; no decoded or verified playable map",
              "files": []}
    for name in SEGMENTS + list(ANCHORS):
        raw = (root / name).read_bytes()
        lines = raw.decode("latin-1").splitlines()
        anchors = {}
        for needle in ANCHORS.get(name, []):
            matches = [i + 1 for i, line in enumerate(lines) if needle in line]
            if len(matches) != 1:
                raise ValueError(f"Expected one {needle!r} in {name}, found {matches}")
            anchors[needle] = matches[0]
        entry = {"file": name, "sha256": hashlib.sha256(raw).hexdigest(),
                 "line_count": len(lines), "anchors": anchors,
                 "source": f"https://github.com/jduerstock/ardungeon/blob/{REVISION}/{name}"}
        if name in SEGMENTS:
            entry["segment_number"] = SEGMENTS.index(name) + 1
            entry["placement_status"] = "unverified; do not infer quadrant from header comments"
        result["files"].append(entry)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("checkout", type=Path)
    parser.add_argument("--output", type=Path, default=Path("docs/map_source_audit.json"))
    args = parser.parse_args()
    result = audit(args.checkout)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"Audited {len(result['files'])} source files; seven candidate map segments. No map imported.")

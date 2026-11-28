extends RefCounted
## Remake geometry revision, separate from the historical map identity.
## Revision 1 changes only S108's three doorways and one wall pair.
const REVISION := 1
const RETIRED_DOOR_KEYS := ["city:26,34:2", "city:26,35:0"]
const ADDED_DOOR_KEYS := ["city:10,30:2", "city:10,31:0", "city:11,31:1",
	"city:12,31:3", "city:10,32:1", "city:11,32:3"]

static func normalized_doors(saved_doors: Dictionary, legacy_geometry: bool) -> Dictionary:
	var result := saved_doors.duplicate(true)
	for key in RETIRED_DOOR_KEYS:
		result.erase(key)
	if legacy_geometry:
		# Old validation accepted arbitrary keys. These six faces were walls, so
		# a legacy key cannot represent a legitimate opening of the new door.
		for key in ADDED_DOOR_KEYS:
			result.erase(key)
	# Preserve unrelated/unknown keys and independent opposite-face state.
	return result

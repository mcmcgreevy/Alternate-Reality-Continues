extends RefCounted
## Single-writer save transaction. The destination is never removed first.
## File-operation methods are overridable for deterministic failure tests.
func write(path: String, text: String) -> Error:
	var temporary := path + ".pending"
	var backup := path + ".previous"
	# Recover an interrupted transaction before touching its only committed copy.
	if not FileAccess.file_exists(path) and FileAccess.file_exists(backup):
		var recovery := move_file(backup, path)
		if recovery != OK:
			return recovery
	var result := write_temporary(temporary, text)
	if result == OK:
		result = replace(temporary, path)
	if result != OK and FileAccess.file_exists(temporary):
		DirAccess.remove_absolute(temporary)
	return result

func write_temporary(path: String, text: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	var result := file.get_error()
	file.close()
	# Detect incomplete writes even when a platform reports no flush error.
	if result == OK and FileAccess.get_file_as_bytes(path) != text.to_utf8_buffer():
		return ERR_FILE_CANT_WRITE
	return result

func replace(temporary: String, destination: String) -> Error:
	# Godot 4.5 Windows rename deletes an existing target before moving. Never
	# rename over the only good save: move it aside first, keeping crash recovery.
	var backup := destination + ".previous"
	var had_save := FileAccess.file_exists(destination)
	if had_save:
		if FileAccess.file_exists(backup):
			var cleanup := DirAccess.remove_absolute(backup)
			if cleanup != OK:
				return cleanup
		var preserve := move_file(destination, backup)
		if preserve != OK:
			return preserve
	var result := move_file(temporary, destination)
	if result != OK and had_save:
		# If rollback also fails, readable_path still exposes the previous save.
		move_file(backup, destination)
	elif result == OK and had_save:
		DirAccess.remove_absolute(backup)
	return result

func readable_path(path: String) -> String:
	if not FileAccess.file_exists(path) and FileAccess.file_exists(path + ".previous"):
		return path + ".previous"
	return path

func move_file(source: String, destination: String) -> Error:
	return DirAccess.rename_absolute(source, destination)

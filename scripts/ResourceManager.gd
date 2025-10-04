extends Node

class_name ResourceManager

static func loadFiles(path : String):
	var files = []
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Не удалось открыть %s" % path)
		return
	for file in dir.get_files():
		if file.ends_with(".remap"):
			file = file.trim_suffix(".remap")
		if file.ends_with(".tscn") || file.ends_with(".tres"):
			var res = load(path + "/" + file)
			if res:
				files.append(res)
			else:
				push_error("Не удалось открыть %s" % file)
	return files

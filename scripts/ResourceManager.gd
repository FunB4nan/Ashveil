extends Node

class_name ResourceManager

static func loadFiles(path : String, withNames : bool = false):
	var files = []
	var dict : Dictionary[String, AudioStream] = {}
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Не удалось открыть %s" % path)
		return
	for file in dir.get_files():
		if file.ends_with(".remap"):
			file = file.trim_suffix(".remap")
		if file.ends_with(".tscn") || file.ends_with(".tres") || file.ends_with(".mp3") || file.ends_with(".wav"):
			var res = load(path + "/" + file)
			if res:
				dict[file.replace(".mp3", "")] = res
				files.append(res)
			else:
				push_error("Не удалось открыть %s" % file)
	if withNames:
		return dict
	else:
		return files

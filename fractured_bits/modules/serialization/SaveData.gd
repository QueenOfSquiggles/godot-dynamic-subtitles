extends Node
"""
Persistence Manager : an autoload script that handles persistence for almost any scene
it does need to be configured to handle specific games but is a really good base for starting out
It does have to be called manually from the scene that needs persistence, so it isn't fully automatic.

"""


# limits the number of objects removed per frame
# this makes sure we don't have a massive stutter at the start of the level
# this could be a const, but I like the idea that specific scenes can set their own rate based on needs unique to that scene
var destructions_per_frame := 50



func get_save_data_for(node : Node) -> Dictionary:
	"""
	The general purpose save data manager
	
	"""
	#if node.filename.empty():
		# node is not instanced. no save data
	#	return {}
		
	var data := {
		"node_path" : get_tree().current_scene.get_path_to(node),
		"node_name" : node.name,
		"extra_data" : "tbd"
	}
	return data

func load_obj_from_data(data : Dictionary) -> void:
	"""
	This method loads in the data and possibly nodes from the data depending on desired functionality
	"""
	var node := get_tree().current_scene.get_node(data["node_path"])
	if node and destruction_queue.has(node):
		# remove this node from the destruction queue
		# really all this does it on/off whether an object is present or not
		# for simple games this is all I need
		# more complex games would need more advanced functionality
		destruction_queue.erase(node)
		#print("Loaded persistent object ", data["node_name"], " at path ", data["node_path"])


"""
	Edit above to customize functionality
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 



	This space intentionally left blank to make the seperation super obvious
"""
#
#	< 0  \|/
#		  3
#	< 0  /|\
#
"""
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	Leave below alone if no advanced changes are needed
"""
signal on_saving
signal on_loading

# the group name for objects recognized as persistent objects
const PERSISTENT_OBJ_GROUP_NAME := "persist"

# a constant prefix for all saves
const SAVE_PATH_PREFIX := "user://saves/"
const SAVE_FILE_TYPE := ".save"

# A custom suffix for setting up a multiple saves system
# this game probably won't use it
var custom_save_suffix := "save_slot/"

# a local queue for destruction. This is loaded 
var destruction_queue := []

const RESOURCE_RESPAWN_PROBABILITY := 0.25

func does_save_data_exist() -> bool:
	var file := open_file(get_current_save_name(), File.READ)
	if not file:
		return false
	var flag := file.file_exists(get_current_save_name())
	file.close()
	return flag

func load_save_data() -> void:
	var file := open_file(get_current_save_name(), File.READ)
	if not file:
		# no file, save data doesn't exist yet
		return
	var line := file.get_line()
	destruction_queue = get_persistant_objs()
	while not line.empty():
		load_obj_from_data(parse_json(line))
		line = file.get_line()
	file.close()
	if not destruction_queue.empty():
		set_process(true)
	emit_signal("on_loading")

func save_data() -> void:
	var dir := Directory.new()
	dir.remove(get_current_save_name()) # delete old file, we want clean data

	# open file for writing (will create a new file)	
	var file := open_file(get_current_save_name(),File.WRITE)
	if not file:
		print("FAILED TO OPEN FILE???")
		return
		
	var scene_objects := get_persistant_objs()
	print("Saving data for ", scene_objects.size(), " persistent objects")
	for i in range(scene_objects.size()):
		var obj := scene_objects[i] as Node
		var data := get_save_data_for(obj)
		if not data.empty():
			file.store_line(to_json(data))
	file.close()
	emit_signal("on_saving")

func get_persistant_objs() -> Array:
	"""
	just a helper method for getting the nodes in the persistent group
	"""
	return get_tree().get_nodes_in_group(PERSISTENT_OBJ_GROUP_NAME)

func _process(_delta: float) -> void:
	"""
	slowly clear out entries in the destruction queue
	"""
	if destruction_queue.empty():
		# once that's empty, nothing more to do
		set_process(false)
		return
	var num := min(destructions_per_frame, destruction_queue.size())
	for i in range(num):
		var entry :Node = destruction_queue[i]
		if not is_instance_valid(entry):
			continue
		if randf() > RESOURCE_RESPAWN_PROBABILITY:
			# eg 0.25 -> 75% chance removal
			# so percentage still works as expected
			entry.queue_free()
		else:
			print("Resource Respawn : ", entry.name, " -> ", entry)
	for i in range(num):
		destruction_queue.remove(0)

func open_file(path: String, open_flags) -> File:
	"""
	Opens the current save file
	"""
	ensure_filepath(get_current_save_dir())
	var file := File.new()
	var err := file.open(path, open_flags)
	if err != OK:
		print("failed to open file : ", path)
		return null
	#print("Opened file [", path, "]")
	return file

func ensure_filepath(path : String) -> void:
	"""
	Make sure the filepath exists so writing out to the file works
	"""
	var dir := Directory.new()
	if dir.file_exists(path):
		return
	var err := dir.make_dir_recursive(path)
	assert(err == OK, "Something failed with creating the path")


func get_current_save_name(suffix : String = "") -> String:
	"""
	Generates a save file path for the currently loaded scene
	This means that we don't need any special logic to save data for a different scene.
	It's all automagic :3
	"""
	var scene_name := get_tree().current_scene.name
	return get_current_save_dir() + scene_name + suffix + SAVE_FILE_TYPE

func get_current_save_dir() -> String:
	return SAVE_PATH_PREFIX + custom_save_suffix

func save_custom_data(suffix : String, data : Dictionary) -> void:
	var dir := Directory.new()
	dir.remove(get_current_save_name(suffix))
	var file := open_file(get_current_save_name(suffix),File.WRITE)
	file.store_var(data, false)
	file.close()

func load_custom_data(suffix : String) -> Dictionary:
	var file := open_file(get_current_save_name(suffix),File.READ)
	if not file:
		return {}

	var v = file.get_var(false)
	var data := v as Dictionary
	file.close()
	return data

func delete_data() -> void:
	print("Deleting save data for : ", get_current_save_dir())
	delete_dir(get_current_save_dir())

func delete_dir(path : String) -> void:
	var dir := Directory.new()
	if not dir.dir_exists(get_current_save_dir()):
		# directory already deleted
		return
	if dir.open(get_current_save_dir()) != OK:
		return
	dir.list_dir_begin()
	var filename := dir.get_next()
	var queue := []
	while filename:
		if dir.current_is_dir():
			if not (filename == ".." or filename == "."):				
				var f_path := path + filename
				print("Adding dir to queue : ", f_path)
				delete_dir(f_path)
		else:
			queue.append(filename)
		filename = dir.get_next()
	dir.list_dir_end()

	for file in queue:
		print("Deleted file : ", file)
		dir.remove(file)
	dir.remove(path)
	print("Deleted dir : ", path)
	

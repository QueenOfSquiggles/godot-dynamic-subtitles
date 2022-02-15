extends Node
"""
QuestManager

A manager for handling Quest resources. It can optionally manage enabling and disabling the quests. There are signals to connect to here so you don't need to connect to each individual quest

"""

signal on_quest_added(quest)
signal on_quest_removed(quest)
signal on_quest_enabled(quest)
signal on_quest_cancelled(quest, is_fail_state)
signal on_quest_completed(quest)


var manage_quests_automatically := true

var loaded_quests := []

var _QUEST_ITR := 0

func add_quest(quest : Quest) -> void:
	if loaded_quests.find(quest) == -1:
		loaded_quests.append(quest)
		emit_signal("on_quest_added", quest)

func load_quest(path : String) -> void:
	var quest :Quest= load(path)
	if quest:
		add_quest(quest)

func load_quests_in_dir(path : String, recursive : bool = true) -> void:
	var dir := Directory.new()
	var err := dir.open(path)
	var queue := []
	if err == OK:
		dir.list_dir_begin(true, true)
		var file_path := dir.get_next()
		while(file_path):
			if dir.dir_exists(file_path) and recursive:
				load_quests_in_dir(file_path)
			else:
				queue.append(file_path)
			file_path = dir.get_next()
		dir.list_dir_end()
	for path in queue:
		load_quest(path)

func unload_quest(quest : Quest) -> void:
	loaded_quests.remove(loaded_quests.find(quest))

func unload_quest_by_name(name : String) -> void:
	var quest := get_quest_by_name(name)
	if quest:
		unload_quest(quest)

func get_quest_by_name(name : String) -> Quest:
	for q in loaded_quests:
		var quest := q as Quest
		if quest.quest_name == name:
			return quest
	return null

func enable_quest(name : String) -> void:
	var quest := get_quest_by_name(name)
	if quest:
		quest.enable_quest()

func _iter_init(arg):
	_QUEST_ITR = 0
	return _QUEST_ITR < loaded_quests.size()

func _iter_next(arg):
	_QUEST_ITR += 1
	return _QUEST_ITR < loaded_quests.size()

func _iter_get(arg) -> Quest:
	return loaded_quests[_QUEST_ITR]

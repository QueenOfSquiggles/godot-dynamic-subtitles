extends Node
class_name SoundLib

func _ready() -> void:
	randomize()

func play(sfx : String = "") -> void:
	if sfx and not sfx.empty():
		var node := get_node(sfx)
		if node:
			if node is AudioStreamPlayer:
				(node as AudioStreamPlayer).stream_paused = false
			if node is KeyedAudioStreamPlayer:
				# automagically play into the sound engine system.
				(node as KeyedAudioStreamPlayer).play_in_engine()
			else:
				node.play()
		else:
			print("failed to find sound library or audio stream named [", sfx, "]")
	else:
		var child_index := randi() % get_child_count()
		get_child(child_index).play()

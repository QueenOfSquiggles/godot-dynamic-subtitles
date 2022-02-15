extends Node

export (Array, PackedScene) var sequence : Array
export (String) var main_scene := ""

var current_index := 0

func _ready() -> void:
	_setup_next_splash()

func _setup_next_splash() -> void:
	if current_index >= sequence.size():
		_complete_sequence()
		return # final sequence is complete

	var packed :PackedScene = sequence[current_index]
	var inst :Splash = packed.instance()
	if not inst:
		current_index+=1
		print("Skipping current")
		_setup_next_splash()
		return # skip this one, failed to load as a splash
	add_child(inst)
	print("Playing splash : ", packed.resource_path)
	inst.animator.play(inst.animation_name)
	inst.animator.connect("animation_finished", self, "_on_splash_finished")
	current_index += 1

func _on_splash_finished(anim_name : String) -> void:
	get_child(0).queue_free()
	_setup_next_splash()

func _complete_sequence() -> void:
	get_tree().change_scene(main_scene)

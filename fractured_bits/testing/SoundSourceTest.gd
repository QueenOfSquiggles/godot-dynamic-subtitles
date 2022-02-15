extends MeshInstance


onready var soundlib := $SoundLib3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("W"):
		soundlib.play("audio")
	if event.is_action_pressed("E"):
		soundlib.play("char_audio")

extends MeshInstance


onready var audio := $AudioTest3D

func _on_Timer_timeout() -> void:
	audio.play()

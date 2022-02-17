extends MeshInstance

export (NodePath) var audio_player : NodePath
onready var audio := get_node(audio_player)

func _ready() -> void:
	audio.play()

func _on_Timer_timeout() -> void:
	audio.play()
	

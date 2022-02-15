extends Node
class_name SubtitleData

export (String) var subtitle_key := ""
export (NodePath) var subtitle_position_override : NodePath

signal on_play

var _last_check := false

onready var parent :Node = get_parent()
onready var pos_override :Node = get_node(subtitle_position_override)

func _process(delta: float) -> void:
	var cur :bool = parent.playing
	if cur and not _last_check:
		trigger_audio_play()

func trigger_audio_play() -> void:
	emit_signal("on_play")
	Subtitles.add_subtitle(self, parent)

extends AudioStreamPlayer3D

signal audio_start

func play(start_time : float = 0.0) -> void:
	.play(start_time) # play parent's function
	emit_signal("audio_start") # emit signal

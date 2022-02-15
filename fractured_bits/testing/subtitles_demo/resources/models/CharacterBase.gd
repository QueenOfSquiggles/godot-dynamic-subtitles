extends Spatial
"""
Just a simple system that plays various sounds at intervals
"""

export (float) var time_between_sounds := 5.0
export (float) var random_extra_time := 1.5
onready var sound_lib := $SoundLib3D
onready var timer := $Timer

func _ready() -> void:
	timer.connect("timeout", self, "do_sound")
	call_deferred("do_sound") # defer so Subtitles can be set up first
	
func do_sound() -> void:
	sound_lib.play() # plays a random sound from the library
	timer.start(time_between_sounds + (randf() * random_extra_time))

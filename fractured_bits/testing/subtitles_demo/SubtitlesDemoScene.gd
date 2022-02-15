extends Spatial
"""
Handles the bare-minimum set-up for subtitles to work and look good enough for a demo
"""

export (Theme) var default_sub_theme : Theme = null

func _ready() -> void:
	SoundEngine.connect("on_sound_played", self, "handle_sound")
	if default_sub_theme:
		Subtitles.subtitle_theme = default_sub_theme

func handle_sound(stream_player, sound_key : String) -> void:
	if sound_key != SoundEngine.DEFAULT_SOUND_KEY:
		# NOTE that here we could also do some logic to pass an override theme for important sounds or differentiate sounds based on the bus they go through by passing a different theme. This is all at the discretion for the user. This is the simplest implementation possible to still achieve a good looking result
		Subtitles.create_subtitle(stream_player, sound_key)

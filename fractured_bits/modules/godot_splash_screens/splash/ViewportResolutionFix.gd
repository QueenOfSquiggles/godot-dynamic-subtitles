extends Viewport


func _ready() -> void:
	# makes this viewport keep size, while the control can scale?
	self.set_size_override(true, self.size)
	self.size_override_stretch = true

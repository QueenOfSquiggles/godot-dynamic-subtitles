extends Spatial

onready var dialogue_sub := $DialogueSub

func _ready():
	dialogue_sub.play()

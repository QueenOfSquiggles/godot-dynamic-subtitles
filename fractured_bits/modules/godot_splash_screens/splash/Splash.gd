extends Node

class_name Splash

export (NodePath) var animator_path : NodePath
export (String) var animation_name := "splash"

onready var animator := get_node(animator_path) as AnimationPlayer

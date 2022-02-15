tool
extends EditorPlugin

const THEMES_SINGLETON_NAME := "Themes"

func _enter_tree() -> void:
	add_autoload_singleton(THEMES_SINGLETON_NAME, "res://addons/ui_theme_manager/Themes.tscn")
	add_custom_type("ThemeLoader", "Node", preload("ThemeLoader.gd"), preload("ThemeIcon.svg"))

func _exit_tree() -> void:
	remove_autoload_singleton(THEMES_SINGLETON_NAME)

extends Node

enum ThemeStyle {
	PRIMARY, SECONDARY, TERTIARY, EXTRA_1, EXTRA_2, BACKUP
}

export (ThemeStyle) var style := ThemeStyle.PRIMARY setget set_style
export (Theme) var backup_theme : Theme setget set_backup

onready var parent := get_parent() as Control

func _ready() -> void:
	set_theme()

func set_style(theme_style : int) -> void:
	style = theme_style
	set_theme()

func set_backup(theme : Theme) -> void:
	backup_theme = theme
	set_theme()

func _on_tree_entered() -> void:
	set_theme()
	Themes.connect("on_theme_changed", self, "set_theme")

func _on_tree_exiting() -> void:
	unset_theme()


func set_theme() -> void:
	var theme := backup_theme
	match(style):
		ThemeStyle.PRIMARY:
			theme = Themes.primary_theme
		ThemeStyle.SECONDARY:
			theme = Themes.secondary_theme
		ThemeStyle.TERTIARY:
			theme = Themes.tertiary_theme
		ThemeStyle.EXTRA_1:
			theme = Themes.extra_theme1
		ThemeStyle.EXTRA_2:
			theme = Themes.extra_theme2
	parent.theme = theme

func unset_theme() -> void:
	parent.theme = null

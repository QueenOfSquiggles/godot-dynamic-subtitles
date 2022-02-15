extends Node

signal on_theme_changed

export (Theme) var primary_theme : Theme setget set_primary
export (Theme) var secondary_theme : Theme setget set_secondary
export (Theme) var tertiary_theme : Theme setget set_tertiary
export (Theme) var extra_theme1 : Theme setget set_extra1
export (Theme) var extra_theme2 : Theme setget set_extra2

func set_primary(theme : Theme) -> void:
	primary_theme = theme
	primary_theme.connect("changed", self, "changed")
	changed()

func set_secondary(theme : Theme) -> void:
	secondary_theme = theme
	secondary_theme.connect("changed", self, "changed")
	changed()

func set_tertiary(theme : Theme) -> void:
	tertiary_theme = theme
	tertiary_theme.connect("changed", self, "changed")
	changed()

func set_extra1(theme : Theme) -> void:
	extra_theme1 = theme
	extra_theme1.connect("changed", self, "changed")
	changed()

func set_extra2(theme : Theme) -> void:
	extra_theme2 = theme
	extra_theme2.connect("changed", self, "changed")
	changed()

func changed() -> void:
	emit_signal("on_theme_changed")

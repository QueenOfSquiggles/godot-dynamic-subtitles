tool
extends EditorPlugin


const MainPanel = preload("res://addons/google_fonts/Menu.tscn")
var main_panel_instance


func _enter_tree():
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)
	main_panel_instance.connect('update_filesystem', self, '_update_filesystem')

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()

func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible

func get_plugin_name():
	return "Fonts"

func has_main_screen():
	return true

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Font", "EditorIcons")

#	var editor_settings = EditorPlugin.get_editor_interface().get_editor_settings()
#	var my_theme = editor_settings.get_setting("interface/theme/preset")

func _update_filesystem():
	get_editor_interface().get_resource_filesystem().scan()

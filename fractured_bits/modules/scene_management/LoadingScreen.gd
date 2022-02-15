extends Control
class_name LoadingScreen

export (String) var LoadingString := "Loading Stage %s of %s"

onready var prog_bar :ProgressBar = $PanelContainer/VBoxContainer/ProgressBar
onready var prog_label : Label = $PanelContainer/VBoxContainer/Label

func update_progress(stage : int, stage_count : int) -> void:
	var stageF := float(stage)
	var stage_countF := float(stage_count)
	var progress := stageF / stage_countF
	#print("Progress : ", int(progress * 100.0), "% -> (", stage, " / ", stage_count, ")")
	prog_bar.value = progress
	prog_label.text = LoadingString % [stage, stage_count]

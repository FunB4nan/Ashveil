@tool
extends EditorPlugin

const SetupDialog = preload("res://addons/tokebi/setup_dialog.gd")
var dock

func _enter_tree():
	dock = SetupDialog.new()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)

func _exit_tree():
	remove_control_from_docks(dock)

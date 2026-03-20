extends Node

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			#Go back to game if user hits Esc key (unpause)
			get_tree().change_scene_to_file("res://Map/test_level.tscn");

func _on_resume_pressed() -> void:
	get_tree().change_scene_to_file("res://Map/test_level.tscn");

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn");

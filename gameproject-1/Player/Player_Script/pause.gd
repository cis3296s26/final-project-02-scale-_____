extends Control

func _ready():
	visible = false
	set_process_input(true)
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			#Go back to game if user hits Esc key (unpause)
			visible = false
			get_tree().paused = false

func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_main_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	GlobalScript.reset_game()
	get_tree().change_scene_to_file("res://scenes/pop-ups/main_menu.tscn")

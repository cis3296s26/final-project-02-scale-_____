extends Control

func _ready():
	visible = true

func show_screen():
	$death.play()
	visible = true
	get_tree().paused = true

func _on_main_menu_pressed() -> void:
	GlobalScript.reset_game()
	get_tree().change_scene_to_file("res://scenes/pop-ups/main_menu.tscn");

func _on_respawn_pressed() -> void:
	print("Respawning...")
	GlobalScript.reset_game()
	if GlobalScript.current_level_path != "":
		get_tree().change_scene_to_file(GlobalScript.current_level_path)

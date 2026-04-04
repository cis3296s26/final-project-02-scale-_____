extends Control

func _ready():
	visible = true

func show_screen():
	visible = true
	get_tree().paused = true

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/pop-ups/main_menu.tscn");

func _on_respawn_pressed() -> void:
	print("Respawning...")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

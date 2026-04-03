extends Node2D

var current_scene

func _ready() -> void:
	current_scene = get_tree().current_scene	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if current_scene.scene_file_path == "res://tutorial_level.tscn":
			get_tree().change_scene_to_file("res://scenes/game.tscn");

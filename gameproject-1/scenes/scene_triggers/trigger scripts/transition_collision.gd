extends Node2D

var current_scene

func _ready() -> void:
	current_scene = get_tree().current_scene	
	print(current_scene)

func _on_body_entered(body: Node2D) -> void:
	print("1")
	if body.name == "Player": 
		print("2")
		get_tree().change_scene_to_file("res://scenes/game.tscn")

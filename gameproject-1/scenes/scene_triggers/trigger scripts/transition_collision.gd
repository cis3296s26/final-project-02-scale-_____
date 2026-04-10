extends Node2D

var current_scene

func _ready() -> void:
	current_scene = get_tree().current_scene	
	print(current_scene)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player"	and current_scene.name == "SubwayTutorial": 
		get_tree().change_scene_to_file("res://scenes/charles_library.tscn")
		
	elif body.name == "Player"	and current_scene.name == "CharlesLibrary": 
		get_tree().change_scene_to_file("res://scenes/game.tscn")
		

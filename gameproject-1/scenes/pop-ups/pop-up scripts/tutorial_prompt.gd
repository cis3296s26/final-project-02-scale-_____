extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_new_game_pressed() -> void:
	print("Skipping Tutorial")
	get_tree().change_scene_to_file("res://scenes/level_2.tscn");


func _on_play_tutorial_pressed() -> void:
	print("Start Tutorial")
	get_tree().change_scene_to_file("res://scenes/tutorial_level.tscn");

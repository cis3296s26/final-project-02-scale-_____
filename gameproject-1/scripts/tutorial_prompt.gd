extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	


func _on_skip_tutorial_pressed() -> void:
	print("Skipping Tutorial")
	get_tree().change_scene_to_file("res://scenes/game.tscn");



func _on_play_tutorial_pressed() -> void:
	print("Starting Tutorial Level")

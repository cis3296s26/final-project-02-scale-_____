extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable Continue if there is no save
	var has_save = false
	# $Container/Continue.disabled = not SaveManager.has_save
	# $Container/Continue.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	print("Prompt for Tutorial")
	get_tree().change_scene_to_file("res://scenes/tutorial_prompt.tscn");


func _on_continue_pressed() -> void:
	print("Continue Game")

func _on_quit_pressed() -> void:
	print("Quitting")
	get_tree().quit()


func _on_options_pressed() -> void:
	print("Options Menu")

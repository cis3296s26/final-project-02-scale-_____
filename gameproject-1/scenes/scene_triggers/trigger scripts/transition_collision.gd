extends Node2D

@export_file("*.tscn") var destination_scene: String
@export var spawn_location_name: String = ""

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if destination_scene != "":
			print("Going to: ", destination_scene)
			get_tree().change_scene_to_file(destination_scene)
		else:
			print("Error: No destination set for this door")

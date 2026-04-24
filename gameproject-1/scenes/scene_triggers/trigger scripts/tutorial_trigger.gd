extends Area2D

@export_multiline var zone_message: String = "Insert Instruction Here"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		var hud = get_tree().current_scene.find_child("TutorialHUD")
		if hud:
			hud.update_text(zone_message)

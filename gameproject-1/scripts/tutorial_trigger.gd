extends Area2D

# This allows you to type the instruction directly in the Godot Inspector!
@export_multiline var zone_message: String = "Insert Instruction Here"

func _on_body_entered(body: Node2D) -> void:
	# Check if the node entering is actually our Owl Player
	if body.name == "Player": 
		# Find the HUD in the current level
		var hud = get_tree().current_scene.find_child("TutorialHUD")
		if hud:
			hud.update_text(zone_message)

#func _on_body_exited(body: Node2D) -> void:
	#if body.name == "Player":
		#var hud = get_tree().current_scene.find_child("TutorialHUD")
		#if hud:
			## Optional: Reset the text or clear it when they leave the area
			#hud.update_text("Next Stop: Cecil B. Moore")

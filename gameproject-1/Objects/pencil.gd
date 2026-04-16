extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("collect"):
		body.collect()
		queue_free()

extends Area2D

var item_id = 1

func _on_body_entered(body: Node2D) -> void:
	var max_allowed = GlobalScript.items[item_id]["Max"]
	
	var current_count = 0
	var item_name = "pencil"
	for i in GlobalScript.inventory:
		if GlobalScript.inventory[i]["Name"].to_lower() == item_name.to_lower():
			current_count = GlobalScript.inventory[i]["Count"]
			print("Current Count: ", current_count)
			break
	
	if current_count < max_allowed:
		if body is CharacterBody2D and body.has_method("collect"):
			body.collect(item_id)
			queue_free()
	else:
		print("Inventory full for this item!")

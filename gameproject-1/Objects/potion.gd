extends Area2D

var item_id = 0

@export var bob_speed: float = 2.0
@export var bob_height: float = 5.0

var time: float = 0.0
@onready var start_y: float = position.y

func _process(delta: float) -> void:
	time += delta
	position.y = start_y + sin(time * bob_speed) * bob_height

func _on_body_entered(body: Node2D) -> void:
	var max_allowed = GlobalScript.items[item_id]["Max"]
	
	var current_count = 0
	var item_name = "Health Potion"
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

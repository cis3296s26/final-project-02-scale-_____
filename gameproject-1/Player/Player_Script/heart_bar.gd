extends CanvasLayer

@onready var container = get_node_or_null("UIRoot/HBoxContainer")

func update_hearts(current_health: int) -> void:
	if not container:
		return
		
	var hearts = container.get_children()
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

func _ready():
	visible = true
	if GlobalScript:
		GlobalScript.health_changed.connect(update_hearts)
		update_hearts(GlobalScript.current_health)
	else:
		print("Still can't find GlobalScript - check Autoload settings!")

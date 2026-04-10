extends CanvasLayer

@onready var container = get_node_or_null("UIRoot/HBoxContainer")

@onready var pencil = get_node_or_null("UIRoot/Pencil")

func update_hearts(current_health: int) -> void:
	if not container:
		return
		
	var hearts = container.get_children()
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

func update_weapon() -> void:
	if GlobalScript.get_weapon():
		pencil.visible = true
	else:
		pencil.visible = false

func _ready():
	visible = true
	pencil.visible = false
	if GlobalScript:
		GlobalScript.health_changed.connect(update_hearts)
		GlobalScript.inventory_changed.connect(update_weapon)
		update_hearts(GlobalScript.current_health)
		update_weapon()
	else:
		print("Still can't find GlobalScript - check Autoload settings!")

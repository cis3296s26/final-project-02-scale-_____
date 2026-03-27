extends CanvasLayer

@onready var heart1 = get_node_or_null("UIRoot/HBoxContainer/Heart1")
@onready var heart2 = get_node_or_null("UIRoot/HBoxContainer/Heart2")
@onready var heart3 = get_node_or_null("UIRoot/HBoxContainer/Heart3")

func update_hearts(current_health: int) -> void:
	if heart1:
		heart1.visible = current_health >= 1
	if heart2:
		heart2.visible = current_health >= 2
	if heart3:
		heart3.visible = current_health >= 3

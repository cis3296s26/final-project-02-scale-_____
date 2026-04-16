extends Panel

var slot: InvSlot

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

func update(new_slot: InvSlot):
	slot = new_slot
	
	if !slot || !slot.item:
		item_visual.visible = false
		amount_text.visible = false
	else:
		var item_tex = slot.item.texture
		
		if item_tex:
			item_visual.visible = true
			item_visual.texture = item_tex
			amount_text.text = ""
			
			if slot.amount > 1:
				amount_text.visible = true
				amount_text.text = str(slot.amount)
			
			var target_size = 16.0 
			var tex_size = item_tex.get_size()
			item_visual.scale = Vector2(target_size / tex_size.x, target_size / tex_size.y)
		else:
			item_visual.visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_slot_clicked()

func on_slot_clicked():
	if slot and slot.item:
		print("Clicked on: ", slot.item.name)
		
		var type = -1
		var item_name
		for i in GlobalScript.items:
			if GlobalScript.items[i]["Name"].to_lower() == slot.item.name.to_lower():
				type = GlobalScript.items[i]["Type"]
				item_name = GlobalScript.items[i]["Name"]
				break
		
		print("Type: ", type)
		
		if type == 0:
			GlobalScript.use_health_potion()
			update(slot)
		
		if type > 0:
			if amount_text.text == "E":
				amount_text.visible = false
				amount_text.text = ""
			else:
				amount_text.visible = true
				amount_text.text = "E"
			equip_effect(type, item_name)

func equip_effect(type: int, item_name: String):
	if type == 1:
		pass
	elif type == 2:
		pass

func _on_mouse_entered() -> void:
	modulate = Color(1.5, 1.5, 1.5)

func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1)

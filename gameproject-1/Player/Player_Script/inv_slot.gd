extends Panel

var slot: InvSlot
var type: int

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
			
			var target_size = 16.0 
			var tex_size = item_tex.get_size()
			item_visual.scale = Vector2(target_size / tex_size.x, target_size / tex_size.y)
			
			for i in GlobalScript.inventory:
				if GlobalScript.inventory[i]["Name"].to_lower() == slot.item.name.to_lower():
					pass
			
			var is_equipped = false
			for i in GlobalScript.inventory:
				if GlobalScript.inventory[i]["Name"].to_lower() == slot.item.name.to_lower():
					is_equipped = GlobalScript.inventory[i]["IsEquipped"]
					type = GlobalScript.inventory[i]["Type"]
					break 

			if is_equipped and type > 0:
				amount_text.text = "E"
				amount_text.visible = true
			elif slot.amount > 1:
				amount_text.text = str(slot.amount)
				amount_text.visible = true
			else:
				amount_text.visible = false
		else:
			item_visual.visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_slot_clicked()

func on_slot_clicked():
	if slot and slot.item:
		print("Clicked on: ", slot.item.name)
		
		type = -1
		var item_name
		for i in GlobalScript.inventory:
			if GlobalScript.inventory[i]["Name"].to_lower() == slot.item.name.to_lower():
				if !GlobalScript.inventory[i]["IsEquipped"]:
					GlobalScript.inventory[i]["IsEquipped"] = true
				else:
					GlobalScript.inventory[i]["IsEquipped"] = false
				
				var current_state = GlobalScript.inventory[i]["IsEquipped"]
				
				print("state: ", current_state)
				
				type = GlobalScript.inventory[i]["Type"]
				item_name = GlobalScript.inventory[i]["Name"]
				
				GlobalScript.inventory_changed.emit()
				break
		
		print("Type: ", type)
		
		if type == 0:
			GlobalScript.use_health_potion()
			update(slot)
		
		if type > 0:
			equip_effect(type, item_name)

func equip_effect(type: int, item_name: String):
	if type == 1:
		GlobalScript.request_equip_effect.emit(type, item_name)
	elif type == 2:
		pass

func _on_mouse_entered() -> void:
	modulate = Color(1.5, 1.5, 1.5)

func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1)

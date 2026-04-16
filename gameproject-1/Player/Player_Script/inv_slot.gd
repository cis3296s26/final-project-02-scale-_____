extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display

func update(slot: InvSlot):
	if !slot || !slot.item:
		# print("No item found for this slot")
		item_visual.visible = false
	else:
		var item_tex = slot.item.texture
		
		if item_tex:
			item_visual.visible = true
			item_visual.texture = item_tex
			
			var target_size = 16.0 
			var tex_size = item_tex.get_size()
			item_visual.scale = Vector2(target_size / tex_size.x, target_size / tex_size.y)
		else:
			item_visual.visible = false

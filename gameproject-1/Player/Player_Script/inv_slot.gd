extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

func update(slot: InvSlot):
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

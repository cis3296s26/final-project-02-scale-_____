extends CanvasLayer

var currItem = 0
var select = 0

@onready var item_sprite = $Control/AnimSprite
@onready var player = get_node("/root/Game/Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_pressed() -> void:
	get_node("Anim").play("TransOut")
	get_tree().paused = false

func switchItem(select):
	for i in range(GlobalScript.items.size()):
		if select == i:
			currItem = select
			
			var tex = GlobalScript.items[currItem]["Texture"]
			item_sprite.texture = tex
			
			get_node("Control/Name").text = GlobalScript.items[currItem]["Name"]
			get_node("Control/Des").text = GlobalScript.items[currItem]["Des"]
			get_node("Control/Des").text += "\nCost: " + str(GlobalScript.items[currItem]["Cost"])
			#print(GlobalScript.items[currItem])
			
			if tex:
				var target_size = 204.0
				var current_res = tex.get_size()
				
				var scale_factor = target_size / max(current_res.x, current_res.y)
				item_sprite.scale = Vector2(scale_factor, scale_factor)

func _on_next_pressed() -> void:
	switchItem(currItem+1)

func _on_prev_pressed() -> void:
	switchItem(currItem-1)
	
func _on_buy_pressed() -> void:
	var hasItem = false
	var checkout = false
	if GlobalScript.coin_count >= GlobalScript.items[currItem]["Cost"]:
		print(currItem)
		GlobalScript.add_item(currItem)
		checkout = GlobalScript.shop_check
		
	if checkout:
		GlobalScript.coin_count -= GlobalScript.items[currItem]["Cost"]
		GlobalScript.inventory_changed.emit()

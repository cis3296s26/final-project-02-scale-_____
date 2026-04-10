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
			item_sprite.texture = GlobalScript.items[currItem]["Texture"]
			get_node("Control/Name").text = GlobalScript.items[currItem]["Name"]
			get_node("Control/Des").text = GlobalScript.items[currItem]["Des"]
			get_node("Control/Des").text += "\nCost: " + str(GlobalScript.items[currItem]["Cost"])
			#print(GlobalScript.items[currItem])

func _on_next_pressed() -> void:
	switchItem(currItem+1)

func _on_prev_pressed() -> void:
	switchItem(currItem-1)
	
func _on_buy_pressed() -> void:
	var hasItem = false
	if GlobalScript.coin_count >= GlobalScript.items[currItem]["Cost"]:
		for i in GlobalScript.inventory:
			if GlobalScript.inventory[i]["Name"] == GlobalScript.items[currItem]["Name"]:
				GlobalScript.inventory[i]["Count"] += 1
				hasItem = true
		
		if hasItem == false:
			var tempDic = GlobalScript.items[currItem].duplicate(true)
			tempDic["Count"] = 1
			GlobalScript.inventory[GlobalScript.inventory.size()] = tempDic
		
		GlobalScript.coin_count -= GlobalScript.items[currItem]["Cost"]
		GlobalScript.inventory_changed.emit()
	
	print(GlobalScript.inventory)

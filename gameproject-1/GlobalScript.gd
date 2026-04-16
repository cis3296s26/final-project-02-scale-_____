extends Node

var max_health = 3
var can_take_damage = true

var shop_check = false

signal health_changed(new_health: int)
signal coin_changed(new_coin_count: int)
signal inventory_changed

@export var item: ItemList

@export var inventory_resource: Inv = preload("res://Player/Player_Script/player_inventory.tres")

var current_health: int = max_health:
	set(value):
		current_health = clamp(value, 0, max_health)
		health_changed.emit(current_health)

var coin_count: int = 999:
	set(value):
		coin_count = max(value, 0)
		coin_changed.emit(coin_count)

var items = {
	0: {
		"Name": "Health Potion",
		"Des": "Heals you 1 missing Heart",
		"Cost": 2,
		"Max": 3,
		"Texture": preload("res://assets/health potion.png"),
		"Resource": preload("res://Player/Player_Script/items/health_potion.tres")
	},
	1: {
		"Name": "Pencil",
		"Des": "This is a No. 2 Pencil",
		"Cost": 5,
		"Max": 1,
		"Texture": preload("res://assets/pencil.png"),
		"Resource": preload("res://Player/Player_Script/items/pencil.tres")
	},
}

var inventory = {

}

func add_item(id: int):
	# 1. Safety check: Does the item exist in our database?
	if not items.has(id):
		print("Error: Item ID ", id, " not found.")
		return

	var item_data = items[id]
	var item_resource = item_data["Resource"]
	
	print (item_resource)
	
	for i in inventory:
		if inventory[i]["Name"] == item_data["Name"]:
			if inventory[i]["Count"] < item_data["Max"]:
				inventory[i]["Count"] += 1
				
				inventory_resource.insert(item_resource)
				
				shop_check = true
				inventory_changed.emit()
				return
			else:
				shop_check = false
				print("Inventory full for: ", item_data["Name"])
				return
				
	var new_index = inventory.size()
	inventory[new_index] = {
		"Name": item_data["Name"],
		"Count": 1,
		"ID": id
	}
	
	inventory_resource.insert(item_resource)
	
	shop_check = true
	inventory_changed.emit()
	
	
func get_health_potion_count() -> int:
	for i in inventory:
		if inventory[i]["Name"] == "Health Potion":
			return inventory[i]["Count"]
	return 0

func get_weapon() -> bool:
	for i in inventory:
		if inventory[i]["Name"] == "Pencil":
			return 1
	return 0

func use_health_potion() -> bool:
	for i in inventory:
		if inventory[i]["Name"] == "Health Potion" and inventory[i]["Count"] > 0:
			inventory[i]["Count"] -= 1
			
			if inventory[i]["Count"] <= 0:
				inventory.erase(i)
			
			inventory_changed.emit()
			return true
	
	return false

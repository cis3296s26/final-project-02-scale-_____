extends Node

var max_health = 7
var can_take_damage = true

var shop_check = false

signal health_changed(new_health: int)
signal coin_changed(new_coin_count: int)
signal inventory_changed

signal request_equip_effect(type: int, item_name: String)

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
		"Type": 0, # Consumable
		"Texture": preload("res://assets/health potion.png"),
		"Resource": preload("res://Player/Player_Script/items/health_potion.tres")
	},
	1: {
		"Name": "Pencil",
		"Des": "This is a No. 2 Pencil",
		"Cost": 5,
		"Max": 1,
		"Type": 1, # Equipable -> Combat
		"Texture": preload("res://assets/pencil.png"),
		"Resource": preload("res://Player/Player_Script/items/pencil.tres")
	},
	2: {
		"Name": "Boots",
		"Des": "HIGHER JUMPS!",
		"Cost": 7,
		"Max": 1,
		"Type": 2, # Equipable -> Movement
		"Texture": preload("res://assets/boots.png"),
		"Resource": preload("res://Player/Player_Script/items/boots.tres")
	},
}

var inventory = {

}

func add_item(id: int):
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
		"ID": id,
		"Type": item_data["Type"],
		"IsEquipped": false
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
	if current_health >= max_health:
		return false
	
	for i in inventory:
		if inventory[i]["Name"] == "Health Potion" and inventory[i]["Count"] > 0:
			inventory[i]["Count"] -= 1
			var new_count = inventory[i]["Count"]
			
			self.current_health += 1
			
			var potion_res = items[0]["Resource"]
			inventory_resource.remove_item(potion_res)
			
			if new_count <= 0:
				inventory.erase(i)
			
			inventory_changed.emit()
			return true
	
	return false

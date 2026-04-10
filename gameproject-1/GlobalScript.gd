extends Node

var max_health = 3
var can_take_damage = true

signal health_changed(new_health: int)
signal coin_changed(new_coin_count: int)
signal inventory_changed

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
		"Texture": preload("res://assets/health potion.png")
	},
	1: {
		"Name": "Pencil",
		"Des": "This is a No. 2 Pencil",
		"Cost": 5,
		"Max": 1,
		"Texture": preload("res://assets/pencil.png")
	},
}

var inventory = {
	0: {
		"Name": "Health Potion",
		"Des": "Heals you 1 missing Heart",
		"Count": 1 
	},
}

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

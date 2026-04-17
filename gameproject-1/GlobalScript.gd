extends Node

var set_coin = 999
var max_health = 4
var can_take_damage = true

var shop_check = false

signal health_changed(new_health: int)
signal coin_changed(new_coin_count: int)
signal inventory_changed

signal request_combat_equip_effect(type: int, item_name: String)
signal request_movement_equip_effect(type: int, item_name: String)

signal remove_combat_equip_effect(type: int, item_name: String)
signal remove_movement_equip_effect(type: int, item_name: String)

@export var item: ItemList

@export var inventory_resource: Inv = preload("res://Player/Player_Script/player_inventory.tres")

var current_level_path: String = ""

var equipped_items = {}

var current_health: int = max_health:
	set(value):
		current_health = clamp(value, 0, max_health)
		health_changed.emit(current_health)

var coin_count: int = set_coin:
	set(value):
		coin_count = max(value, 0)
		coin_changed.emit(coin_count)

func reset_game():
	inventory.clear() 
	for slot in inventory_resource.slots:
		slot.item = null
		slot.amount = 0
	inventory_changed.emit()
	current_health = max_health
	coin_count = set_coin

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
		"Type": 1, # Equipable -> Weapon
		"Texture": preload("res://assets/pencil.png"),
		"Resource": preload("res://Player/Player_Script/items/pencil.tres")
	},
	2: {
		"Name": "Jump_Boots",
		"Des": "TWICE THE JUMPS!",
		"Cost": 10,
		"Max": 1,
		"Type": 2, # Equipable -> Movement
		"Texture": preload("res://assets/boots.png"),
		"Resource": preload("res://Player/Player_Script/items/jump_boots.tres")
	},
	3: {
		"Name": "Dash_Boots",
		"Des": "GO FURTHER WITH EVERY PRESS!",
		"Cost": 7,
		"Max": 1,
		"Type": 2, # Equipable -> Movement
		"Texture": preload("res://assets/dash_boots.png"),
		"Resource": preload("res://Player/Player_Script/items/dash_boots.tres")
	},
	4: {
		"Name": "Glide_Up",
		"Des": "Stay in the air for longer",
		"Cost": 2,
		"Max": 1,
		"Type": 2, # Equipable -> Movement
		"Texture": preload("res://assets/glide_up.png"),
		"Resource": preload("res://Player/Player_Script/items/glide_up.tres")
	},
	5: {
		"Name": "Backpack",
		"Des": "Hit them hard with misc. books",
		"Cost": 12,
		"Max": 1,
		"Type": 1, # Equipable -> Combat
		"Texture": preload("res://assets/backpack.png"),
		"Resource": preload("res://Player/Player_Script/items/backpack.tres")
	},
	6: {
		"Name": "Damage_Up",
		"Des": "Increase Damage",
		"Cost": 4,
		"Max": 1,
		"Type": 1, # Equipable -> Combat
		"Texture": preload("res://assets/damage_up.png"),
		"Resource": preload("res://Player/Player_Script/items/damage_up.tres")
	},
	7: {
		"Name": "Speed_Up",
		"Des": "Increase Speed",
		"Cost": 4,
		"Max": 1,
		"Type": 2, # Equipable -> Movement
		"Texture": preload("res://assets/speed_up.png"),
		"Resource": preload("res://Player/Player_Script/items/speed_up.tres")
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
		if inventory[i] == null:
			continue 
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

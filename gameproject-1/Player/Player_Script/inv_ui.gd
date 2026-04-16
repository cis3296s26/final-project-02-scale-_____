extends Control

@onready var inv: Inv = preload("res://Player/Player_Script/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready() -> void:
	GlobalScript.inventory_changed.connect(updatefunction)
	updatefunction()

func updatefunction() -> void:
	for i in range(min(inv.slots.size(), slots.size())):
		if slots[i].has_method("update"):
			slots[i].update(inv.slots[i])

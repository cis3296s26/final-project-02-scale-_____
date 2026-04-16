extends Control

@onready var inv: Inv = preload("res://Player/Player_Script/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inv.inventory_updated.connect(updatefunction)
	updatefunction()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func updatefunction() -> void:
	for i in range(min(inv.items.size(), slots.size())):
		if slots[i].has_method("update"):
			slots[i].update(inv.items[i])

extends Node

var max_health = 3
var can_take_damage = true

signal health_changed(new_health: int)

var current_health: int = 3:
	set(value):
		current_health = clamp(value, 0, max_health)
		health_changed.emit(current_health)

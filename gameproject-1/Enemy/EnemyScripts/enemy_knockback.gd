extends Node2D

@export var knockback_force: float = 200.0

func apply_knockback(enemy: CharacterBody2D, weapon_position: Vector2):
	var direction_damage = (enemy.global_position - weapon_position).normalized()
	print("Enemy: ", direction_damage)
	enemy.velocity = Vector2(direction_damage.x * knockback_force, -200)

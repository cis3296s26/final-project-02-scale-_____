extends Node

@onready var sprite = $"../AnimatedSprite2D"
var isAttacking = false
signal attack_state_changed(isAttacking: bool)
@onready var weapon_hitbox = $AttackCollision/CollisionShape2D
var damage_value = 1

@onready var weapon_node = get_tree().root.find_child("Pencil", true, false)

func handle_combat(player: CharacterBody2D,  animated: AnimatedSprite2D) -> void:
	if Input.is_action_just_pressed("drop"):
		weapon_node.visible = false
		for i in GlobalScript.inventory:
			if GlobalScript.inventory[i]["Name"] == "Pencil":
				GlobalScript.inventory[i]["Count"] -= 1
	
	handle_combat_animations(player, animated)

func handle_combat_animations(player: CharacterBody2D, animated: AnimatedSprite2D) -> void:
	if Input.is_action_just_pressed("attack"):
		if player.is_on_floor():
			animated.play("owl_attack")
			$AttackCollision/CollisionShape2D.position = Vector2(9, -3)
			$AttackCollision/CollisionShape2D.shape.size = Vector2(5, 10)
			$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
			isAttacking = true	
			attack_state_changed.emit(true)
		else:
			animated.play("owl_glide_attack")
			$AttackCollision/CollisionShape2D.position = Vector2(9, -3)
			$AttackCollision/CollisionShape2D.shape.size = Vector2(10, 10)
			$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
			isAttacking = true	
			attack_state_changed.emit(true)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "owl_attack" or sprite.animation == "owl_glide_attack" or sprite.animation == "owl_weapon_1":
		$AttackCollision/CollisionShape2D.set_deferred("disabled", true)
		isAttacking = false
		attack_state_changed.emit(false)

func _on_attack_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") and isAttacking == true:
		$AttackCollision/CollisionShape2D.set_deferred("disabled", true)
		isAttacking = false
		attack_state_changed.emit(false)
		var weapon_pos = weapon_hitbox.global_position
		area.owner._damage(damage_value, weapon_pos)

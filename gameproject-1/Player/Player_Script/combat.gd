extends Node

@onready var sprite = $"../AnimatedSprite2D"
var isAttacking = false
signal attack_state_changed(isAttacking: bool)
@onready var weapon_hitbox = $AttackCollision/CollisionShape2D
var damage_value = 1
var old_damage

var weapon_flag = 0

@onready var weapon_node = get_tree().root.find_child("Pencil", true, false)

func _ready():
	GlobalScript.request_combat_equip_effect.connect(_on_equip_requested)
	GlobalScript.remove_combat_equip_effect.connect(_on_equip_remove)

func _on_equip_requested(type: int, item_name: String):
	if item_name.to_lower() == "pencil":
		weapon_flag = 1
		print("enable1: ",weapon_flag)
	elif item_name.to_lower() == "backpack":
		weapon_flag = 2
		damage_value += 2
		print("enable2: ",weapon_flag)
	elif item_name.to_lower() == "damage_up":
		damage_value += 1
		print("Damage Value: ", damage_value)

func _on_equip_remove(type: int, item_name: String):
	if item_name.to_lower() == "pencil":
		weapon_flag = 0
		damage_value -= 1
		print("disable1: ",weapon_flag)
	elif item_name.to_lower() == "backpack":
		weapon_flag = 0
		damage_value -= 2
		print("disable2: ",weapon_flag)
	elif item_name.to_lower() == "damage_up":
		damage_value -= 1
		print("Damage Value: ", damage_value)

func handle_combat(player: CharacterBody2D,  animated: AnimatedSprite2D) -> void:
	handle_combat_animations(player, animated)

func handle_combat_animations(player: CharacterBody2D, animated: AnimatedSprite2D) -> void:
	if Input.is_action_just_pressed("attack"):
		if player.is_on_floor():
			if weapon_flag == 0:
				animated.play("owl_attack")
				$AttackCollision/CollisionShape2D.position = Vector2(9, -3)
				$AttackCollision/CollisionShape2D.shape.size = Vector2(5, 10)
				$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
				print(damage_value)
				isAttacking = true	
				attack_state_changed.emit(true)
			elif weapon_flag == 1:
				animated.play("owl_weapon_1")
				$AttackCollision/CollisionShape2D.position = Vector2(14, -3)
				$AttackCollision/CollisionShape2D.shape.size = Vector2(20, 10)
				$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
				print(damage_value)
				isAttacking = true	
				attack_state_changed.emit(true)
			elif weapon_flag == 2:
				animated.play("owl_weapon_2")
				$AttackCollision/CollisionShape2D.position = Vector2(9, -3)
				$AttackCollision/CollisionShape2D.shape.size = Vector2(5, 10)
				$Timer.start(0.5)
				isAttacking = true	
				attack_state_changed.emit(true)
		else:
			animated.play("owl_glide_attack")
			$AttackCollision/CollisionShape2D.position = Vector2(9, -3)
			$AttackCollision/CollisionShape2D.shape.size = Vector2(10, 10)
			$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
			print(damage_value)
			isAttacking = true	
			attack_state_changed.emit(true)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "owl_attack" or sprite.animation == "owl_glide_attack" or sprite.animation == "owl_weapon_1" or sprite.animation == "owl_weapon_2":
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

func _on_delayed_timeout() -> void:
	$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
	print(damage_value)

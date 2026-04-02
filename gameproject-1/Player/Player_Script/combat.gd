extends Node

@onready var sprite = $"../AnimatedSprite2D"
var isAttacking = false

func handle_combat(player: CharacterBody2D,  animated: AnimatedSprite2D) -> void:
	handle_combat_animations(animated)

func handle_combat_animations(animated: AnimatedSprite2D) -> void:
	if Input.is_action_just_pressed("attack"):
		animated.play("owl_attack")
		$AttackCollision/CollisionShape2D.position = Vector2(9, -3)
		$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
		isAttacking = true	
		
	elif animated.animation != "owl_attack" and isAttacking:
		$AttackCollision/CollisionShape2D.set_deferred("disabled", true)
		isAttacking = false

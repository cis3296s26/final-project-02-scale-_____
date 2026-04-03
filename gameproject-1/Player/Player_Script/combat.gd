extends Node

@onready var sprite = $"../AnimatedSprite2D"
var isAttacking = false
signal attack_state_changed(isAttacking: bool)

func handle_combat(player: CharacterBody2D,  animated: AnimatedSprite2D) -> void:
	handle_combat_animations(animated)

func handle_combat_animations(animated: AnimatedSprite2D) -> void:
	if Input.is_action_just_pressed("attack"):
		animated.play("owl_attack")
		$AttackCollision/CollisionShape2D.position = Vector2(10, -3)
		$AttackCollision/CollisionShape2D.set_deferred("disabled", false)
		isAttacking = true	
		attack_state_changed.emit(true)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "owl_attack":
		$AttackCollision/CollisionShape2D.set_deferred("disabled", true)
		isAttacking = false
		attack_state_changed.emit(false)

extends CharacterBody2D

## Configuration
@export var speed: float = 80.0
@export var damage_value: int = 1
@export var max_health: int = 6

## State
var health: int = max_health
var death: bool = false
var is_knocking_back: bool = false
var player: Node2D = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_shape: CollisionShape2D = $attack/CollisionShape2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var knockback_timer: Timer = $knockbackTimer
@onready var knockback = $EnemyKnockback

func _physics_process(delta: float) -> void:
	if death:
		velocity.x = move_toward(velocity.x, 0, speed) # Slow down to a stop
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += 980 * delta

	if not is_knocking_back:
		if player:
			var direction = (player.global_position - global_position).normalized()
			
			velocity.x = direction.x * speed
		
			if direction.x != 0:
				anim.flip_h = direction.x < 0
				anim.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			anim.play("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, 10.0) 

	move_and_slide()

func _damage(amount: int, weapon_position: Vector2) -> void:
	if death: return 
	
	health -= amount
	print("Hit! Health is now: ", health)
	
	if health <= 0:
		die()
		return
	
	is_knocking_back = true
	if knockback:
		knockback.apply_knockback(self, weapon_position)
	
	knockback_timer.start(0.5)

	anim.modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)

func die() -> void:
	death = true
	anim.play("dead")
	print("DEATH")
	
	set_collision_layer_value(1, false) 

	if body_shape:
		body_shape.set_deferred("disabled", true)
	if attack_shape:
		attack_shape.set_deferred("disabled", true)

func _on_knockback_timer_timeout() -> void:
	is_knocking_back = false

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _on_attack_body_entered(body: Node2D) -> void:
	# This handles the enemy hitting the player
	if body.has_method("take_damage") and not death:
		body.take_damage(damage_value, global_position)

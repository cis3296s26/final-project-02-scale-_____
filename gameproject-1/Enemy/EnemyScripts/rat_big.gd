extends CharacterBody2D

@export var speed: float = 80.0
@export var damage_value: int = 1
@export var max_health: int = 3

var health: int = max_health
var death: bool = false
var is_knocking_back: bool = false
var player: Node2D = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_hitbox: CollisionShape2D = $attack/CollisionShape2D
@onready var knockback_timer: Timer = $knockbackTimer

@onready var knockback = $EnemyKnockback

func _physics_process(delta: float) -> void:
	if death:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += 980 * delta

	if not is_knocking_back:
		if player:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			
			anim.flip_h = velocity.x < 0
			anim.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			anim.play("idle")

	move_and_slide()

func die() -> void:
	death = true
	anim.play("dead")
	print("DEATH")
	set_collision_layer_value(1, false) 
	if enemy_hitbox:
		$CollisionShape2D.set_deferred("disabled", true)
		enemy_hitbox.set_deferred("disabled", true)

func _on_knockback_timer_timeout() -> void:
	is_knocking_back = false
	if has_node("EnemyHitbox/HitboxShape"):
		$EnemyHitbox/HitboxShape.set_deferred("disabled", false)
		
func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not death:
		body.take_damage(damage_value, global_position)


func _damage(amount: int, weapon_position: Vector2) -> void:
	health = health - amount
	
	if health <= 0:
		anim.play("dead")
		print("DEATH")
		death = true
		enemy_hitbox.queue_free()
		return
	
	is_knocking_back = true
	knockback.apply_knockback(self, weapon_position)
	print("Hit! Health is now: ", health)

	$knockbackTimer.start(0.5)

extends CharacterBody2D

@export var damage_value = 1

@export var speed: float = 100.0
@export var detection_range: float = 200.0
@export var gravity: float = 800.0
@export var preferred_distance: float = 40.0
@export var distance_tolerance: float = 10.0
@export var ideal_spot: float = 0.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $EnemySprite1
@onready var animhit = $CollisionShape2D
@onready var weapon_hitbox = $WeaponHitbox
@onready var enemy_hitbox = $EnemyHitbox
@export var attack_thrust: float = 0.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts
	
@onready var knockback = $EnemyKnockback
	
var state = "idle"
var attack_timer: float = 0.3
var death = false
var  is_knocking_back = false
var max_heath = 3
var health = 3

func _physics_process(delta):
	if is_knocking_back:
		velocity.y += 980 * delta 
		move_and_slide()
		return
	
	if death:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if player == null:
		anim.play("jan_idle")
		velocity.x = 0
		move_and_slide()
		return #
	
	var distance = global_position.distance_to(player.global_position)
	
	# Determine state
	if ideal_spot == 1.0:
		state = "attack"
	elif distance <= detection_range:
		state = "chase"
	else:
		state = "idle"
	
	match state:
		"idle":
			idle(delta)
		"chase":
			chase(delta)
		"attack":
			attack(delta)

func idle(delta):
	apply_gravity(delta)
	anim.play("jan_idle")
	move_and_slide()

func chase(delta):
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var direction = to_player.normalized()
	
	# Flip sprite
	anim.flip_h = player.global_position.x < global_position.x
	
	if anim.flip_h:
		animhit.position.x = 30
		enemy_hitbox.position.x = 30
		weapon_hitbox.position.x = -5
		preferred_distance = 7.0
		
	else:
		animhit.position.x = 10
		enemy_hitbox.position.x = 10
		weapon_hitbox.position.x = 0
		preferred_distance = 40.0

	# Maintain distance
	if distance > preferred_distance + distance_tolerance:
		# Too far → move closer
		velocity.x = direction.x * speed
		anim.play("jan_walk")
	elif distance < preferred_distance - distance_tolerance:
		# Too close → move away
		velocity.x = -direction.x * speed
		anim.play("jan_walk")
	else:
		# Ideal distance → stop moving
		ideal_spot = 1.0
		velocity.x = 0
		anim.play("jan_idle")

	apply_gravity(delta)
	move_and_slide()

func attack(delta):
	if attack_timer <= 0:
		# Start attack
		attack_timer = attack_duration
		weapon_hitbox.monitoring = true  # enable hitbox
		anim.play("jan_attack")
		# Determine thrust direction
		weapon_hitbox.position.x = 10 if anim.flip_h == false else -10
	else:
		# Continue attack
		var thrust_dir = 1 if anim.flip_h == false else -1
		velocity.x = thrust_dir * attack_thrust
		apply_gravity(delta)
		move_and_slide()
		attack_timer -= delta
		if attack_timer <= 0:
			# End attack
			velocity.x = 0
			ideal_spot = 0.0
			weapon_hitbox.monitoring = false
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # reset vertical speed when on the floor

func _on_weapon_hitbox_body_entered(body: Node2D) -> void:
	if state == "attack" and body.has_method("take_damage"):
		var weapon_pos = weapon_hitbox.global_position
		body.take_damage(damage_value, weapon_pos)
	
func _on_enemy_sprite_1_animation_finished() -> void:
	if anim.animation == "jan_hit":
		if death:
			print("Play Sprite")
			anim.play("jan_death")
		else:
			anim.play("jan_idle")

func _damage(amount: int, weapon_position: Vector2) -> void:
	health = health - amount
	
	if health <= 0:
		anim.play("jan_death")
		print("DEATH")
		death = true
		weapon_hitbox.queue_free()
		enemy_hitbox.queue_free()
		animhit.queue_free()
		return
	
	is_knocking_back = true
	knockback.apply_knockback(self, weapon_position)
	print("Hit! Health is now: ", health)
	anim.play("jan_hit")
	$EnemyHitbox/HitboxShape.set_deferred("disabled", true)
	$knockbackTimer.start(0.5)
	
func _on_knockback_timer_timeout() -> void:
	if has_node("EnemyHitbox/HitboxShape"):
		$EnemyHitbox/HitboxShape.set_deferred("disabled", false)
	is_knocking_back = false

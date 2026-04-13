extends CharacterBody2D

@export var damage_value = 1

@export var speed: float = 60.0
@export var detection_range: float = 150.0
@export var attack_range: float = 50.0
@export var gravity: float = 800.0
@export var glide_gravity: float = 100.0 # slower fall
@export var jump_force: float = -300.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $AnimatedSprite2D
@onready var animhit = $CollisionShape2D
@export var attack_thrust: float = 100.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts
@onready var knockback = $EnemyKnockback
	
var state = "idle"
var death = false
var max_heath = 2
var health = 2
var can_take_damage: bool = true
var attack_timer: float = 0.0
var damage_cooldown_current = 0.0
var damage_cooldown_max = 0.2
var justDied: bool = false
var wander_timer: float = 0.0
var wander_duration: float = 2.0
var wander_direction: float = 0.0  # -1 = left, 0 = still, 1 = right
var is_knocking_back = false

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if death:
		if justDied: apply_gravity(delta)
		velocity.x = 0
		move_and_slide()
		return
	
	if is_knocking_back:
		apply_gravity(delta)
		if is_on_floor():
			velocity.y = 0
		move_and_slide()
		if is_on_floor():
			is_knocking_back = false
			can_take_damage = true
		return

	if get_slide_collision_count() > 0 and abs(get_slide_collision(0).get_normal().x) > 0.9:
		velocity.x = 0
		wander_timer = 0
		if state == "chase":
			state = "idle"

	if damage_cooldown_current > 0:
		damage_cooldown_current -= delta
	
	var distance = global_position.distance_to(player.global_position)
	
	# Determine state
	if distance <= attack_range:
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
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
	
		if state == "attack" and damage_cooldown_current <=0 and body.has_method("take_damage"):
			var weapon_pos = animhit.global_position
			body.take_damage(damage_value, weapon_pos)
			damage_cooldown_current = damage_cooldown_max
		

func idle(delta):
	if death: return
	# if not is_on_floor():
		# velocity.y += 0
		# anim.play("mid_air")
	apply_gravity(delta)
	if !is_on_floor():
		move_and_slide()
		return
	wander_timer -= delta
	if wander_timer <= 0:
		# Pick random direction
		wander_direction = randf_range(-1, 1)  # -1 to 1
		anim.play("walk")
		if wander_direction < -0.33:
			wander_direction = -1
		elif wander_direction > 0.33:
			wander_direction = 1
		else:
			anim.play("still")
			wander_direction = 0  # stand still
		wander_timer = wander_duration
	# Move based on chosen direction
	velocity.x = wander_direction * speed * 0.75 # go slower if not chasing
	move_and_slide()
	
	if wander_direction != 0:
		anim.flip_h = wander_direction > 0

func chase(delta):
	if is_on_floor(): anim.play("walk")
	var direction = sign(player.global_position.x - global_position.x)
	anim.flip_h = player.global_position.x > global_position.x
	can_take_damage = true
	velocity.x = direction * speed
	apply_gravity(delta)
	move_and_slide()

func attack(delta):
	if attack_timer <= 0 and is_on_floor():
		# Start attack
		attack_timer = attack_duration
		anim.play("attack")
		global_position.y -= 15
	else:
		# Continue attack
		var dir = sign(player.global_position.x - global_position.x)
		#if velocity.y < 0:
			# going UP → move AWAY from player
		#	velocity.x = -dir * attack_thrust
		#else:
			# going DOWN → barely move (or slight toward player)
		velocity.x = dir * attack_thrust
		can_take_damage = true
		apply_gravity(delta)
		move_and_slide()
		attack_timer -= delta
		if attack_timer <= 0:
			# End attack
			velocity.x = 0
	
func apply_gravity(delta):
	if not is_on_floor():
		anim.play("mid_air")
		if velocity.y < 0:
			# going UP → normal gravity (so it slows quickly)
			velocity.y += gravity * delta
		else:
			# going DOWN → glide
			velocity.y += glide_gravity * delta
		if is_on_floor(): return
	else:
		velocity.y = 0
		if death:
			$CollisionShape2D.set_deferred("disabled", true)
			justDied = false


func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	if death or !can_take_damage: return
	health = health - 1
	if health <= 0:
		anim.play("death")
		justDied = true
		print("PIGEON DEATH")
		death = true
		return
	is_knocking_back = true
	knockback.apply_knockback(self, global_position)
	print("Hit! Health is now: ", health)
	anim.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.2).timeout
	anim.modulate = Color(1, 1, 1)
	can_take_damage = false
	$knockbackTimer.start(0.5)

func _on_knockback_timer_timeout() -> void:
	can_take_damage = true
	is_knocking_back = false

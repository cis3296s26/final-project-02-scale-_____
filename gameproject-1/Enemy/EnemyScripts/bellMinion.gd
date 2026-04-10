extends CharacterBody2D


@export var speed: float = 60.0
@export var detection_range: float = 150.0
@export var attack_range: float = 50.0
@export var gravity: float = 800.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $AnimatedSprite2D
@onready var animhit = $CollisionShape2D
@export var attack_thrust: float = 100.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts

var state = "idle"
var death = false
var max_heath = 1
var health = 1
var attack_timer: float = 0.0
var damage_cooldown_current = 0.0
var damage_cooldown_max = 0.3

var wander_timer: float = 0.0
var wander_duration: float = 2.0
var wander_direction: float = 0.0  # -1 = left, 0 = still, 1 = right

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if player == null:
		anim.play("still")
		velocity.x = 0
		# move_and_slide()
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
			body.take_damage(1)
			damage_cooldown_current = damage_cooldown_max
		

func idle(delta):
	# if not is_on_floor():
		# velocity.y += 0
		# anim.play("mid_air")
	apply_gravity(delta)
	wander_timer -= delta
	if wander_timer <= 0:
		# Pick random direction
		wander_direction = randf_range(-1, 1)  # -1 to 1
		anim.play("ring")
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
	var direction = sign(player.global_position.x - global_position.x)
	anim.flip_h = player.global_position.x > global_position.x

	velocity.x = direction * speed
	apply_gravity(delta)
	move_and_slide()
	anim.play("ring")

func attack(delta):
	if attack_timer <= 0:
		# Start attack
		attack_timer = attack_duration
		anim.play("ring")
	else:
		# Continue attack
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * attack_thrust
		apply_gravity(delta)
		move_and_slide()
		attack_timer -= delta
		if attack_timer <= 0:
			# End attack
			velocity.x = 0
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		anim.play("still")
	else:
		velocity.y = 0  # reset vertical speed when on the floor


func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	if death:
		$CollisionShape2D.set_deferred("disabled", true)
		return
	
	if area.is_in_group("attack"):
		health = health - 1
		print("Hit! Health is now: ", health)
		if health <= 0:
			queue_free()
			print("DEATH")
			death = true

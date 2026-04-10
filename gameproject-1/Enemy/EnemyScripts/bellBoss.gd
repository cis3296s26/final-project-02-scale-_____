extends CharacterBody2D

@export var spawn_enemy_scene: PackedScene

@export var speed: float = 20.0
@export var attack_range: float = 70.0
@export var gravity: float = 800.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $AnimatedSprite2D
@onready var animhit = $CollisionShape2D
@export var attack_thrust: float = 30.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts

@export var damage_value = 1
var state = "chase"
var death = false
var phase = 1

var max_health_phase1 = 1
var max_health_phase2 = 1
var health = 1
var attack_timer: float = 0.0
var damage_cooldown_current = 0.0
var damage_cooldown_max = 0.5
var shake_timer = 0.0
var shake_strength = 2.0

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if player == null:
		if phase == 1:
			anim.play("still1")
		else:
			anim.play("still2")
		velocity.x = 0
		# move_and_slide()
		return

	if damage_cooldown_current > 0:
		damage_cooldown_current -= delta
	
	if state != "transitioning" and state != "death":
		var distance = global_position.distance_to(player.global_position)
		
		# Determine state
		if distance <= attack_range:
			state = "attack"
		else:
			state = "chase"

	match state:
		"chase":
			chase(delta)
		"attack":
			attack(delta)
		"transitioning":
			transitioning()
		"dead":
			dead()
	
	if state == "attack" and damage_cooldown_current <=0 and player.has_method("take_damage"):
		if _is_player_hit_by_swing():
			var weapon_pos = animhit.global_position
			player.take_damage(damage_value, weapon_pos)
			damage_cooldown_current = damage_cooldown_max
	
	if phase == 2 and state != "transitioning" and state != "death":
		if shake_timer > 0:
			shake_timer -= delta
			# randomly choose left or right
			var rand = randf()
			if rand < 0.5:
				$AnimatedSprite2D.position.x = shake_strength * rand
				if rand < 0.1:
					speed += randf() * 40
					attack_thrust += randf() * 40
			else:
				$AnimatedSprite2D.position.x = -shake_strength * rand
				speed = 40.0
				attack_thrust = 30.0
		else:
			# reset position
			$AnimatedSprite2D.position.x = 0
			# randomly start shaking
			if randf() < 0.02:
				shake_timer = randf_range(0.1, 0.5)

func chase(delta):
	if death: return
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * speed
	apply_gravity(delta)
	move_and_slide()
	if phase == 1:
		anim.play("ring1")
	elif phase == 2:
		anim.play("ring2")

func attack(delta):
	if death: return
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
			# queue_free()
			if phase == 1:
				phase = 2
				print("BELL BOSS PHASE 2")
				state = "transitioning"
			else:
				print("BELL BOSS DEATH")
				anim.play("death")
				state = "dead"
				phase = 3
				death = true

func _is_player_hit_by_swing():
	if death: return
	var frame = $AnimatedSprite2D.frame
	var dir = sign(player.global_position.x - global_position.x)
	
	if frame >= 1 and frame <= 6:
		# left swing
		if dir == 1: return 1
	elif frame >= 11 and frame <= 16:
		# right swing
		if dir == -1: return 1
	# no hit
	return 0
	
func transitioning():
	anim.play("crack_phase_transition")
	health = 100
	await get_tree().process_frame  # let animation start
	while $AnimatedSprite2D.frame < 11:
		await get_tree().process_frame
	if anim.animation == "crack_phase_transition":
		health = max_health_phase2
		phase = 2
		state = "chase"

func dead():
	anim.play("death")
	health = 100
	await get_tree().process_frame  # let animation start
	while $AnimatedSprite2D.frame < 14:
		await get_tree().process_frame

extends CharacterBody2D

@export var speed: float = 20.0
@export var attack_range: float = 100.0
@export var gravity: float = 800.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $AnimatedSprite2D
@onready var animhit = $CollisionShape2D
@export var attack_thrust: float = 10.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts

var state = "chase"
var death = false
var max_heath = 30
var health = 30
var attack_timer: float = 0.0
var damage_cooldown_current = 0.0
var damage_cooldown_max = 0.5

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if player == null:
		anim.play("still")
		velocity.x = 0
		# move_and_slide()
		return

	if damage_cooldown_current > 0:
		damage_cooldown_current -= delta
	
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
		# "ring"
			# ring(delta)
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
	
		if state == "attack" and damage_cooldown_current <=0 and body.has_method("take_damage"):
			if _is_player_hit_by_swing():
				# damaged
				body.take_damage(1)
				damage_cooldown_current = damage_cooldown_max

func chase(delta):
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * speed
	apply_gravity(delta)
	move_and_slide()
	anim.play("ring")
	# if (timer == )
		# state = "ring"

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

func _is_player_hit_by_swing():
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

extends CharacterBody2D


@export var speed: float = 60.0
@export var detection_range: float = 150.0
@export var attack_range: float = 50.0
@export var gravity: float = 200.0


@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $AnimatedSprite2D
@onready var animhit = $CollisionShape2D
@export var attack_thrust: float = 100.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts
	
var state = "idle"
var attack_timer: float = 0.0

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if player == null:
		anim.play("still")
		velocity.x = 0
		# move_and_slide()
		return
	
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

func idle(delta):
	# if not is_on_floor():
		# velocity.y += 0
		# anim.play("mid_air")
	apply_gravity(delta)
	anim.play("still")
	# move_and_slide()

func chase(delta):
	var direction = sign(player.global_position.x - global_position.x)
	anim.flip_h = player.global_position.x > global_position.x
	
	if anim.flip_h:
		animhit.position.x = 0
		
	else:
		animhit.position.x = 0
	
	if player.global_position.x < global_position.x:
		velocity.x = 0
	
	velocity.x = direction * speed
	apply_gravity(delta)
	move_and_slide()
	anim.play("walk")

func attack(delta):
	if attack_timer <= 0:
		# Start attack
		attack_timer = attack_duration
		anim.play("attack")
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
		anim.play("mid_air")
	else:
		velocity.y = 0  # reset vertical speed when on the floor

func _player_body_attacked(body: Node2D) -> void:
	if state == "attack" and body.has_method("take_damage"):
		body.take_damage(1)

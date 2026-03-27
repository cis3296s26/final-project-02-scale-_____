extends CharacterBody2D


@export var speed: float = 100.0
@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var gravity: float = 800.0


@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $EnemySprite1
@onready var animhit = $CollisionShape2D
@onready var weapon_hitbox = $WeaponHitbox
@export var attack_thrust: float = 150.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts
	
var state = "idle"
var attack_timer: float = 0.0

func _physics_process(delta):
	if player == null:
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
	apply_gravity(delta)
	anim.play("jan_idle")
	move_and_slide()

func chase(delta):
	var direction = (player.global_position - global_position).normalized()
	anim.flip_h = player.global_position.x < global_position.x
	if player.global_position.x < global_position.x:
		animhit.position.x = 20
	else :
		animhit.position.x = 0
	
	velocity.x = direction.x * speed
	apply_gravity(delta)
	move_and_slide()
	anim.play("jan_walk")

func attack(delta):
	if attack_timer <= 0:
		# Start attack
		attack_timer = attack_duration
		weapon_hitbox.monitoring = true  # enable hitbox
		anim.play("jan_attack")
		# Determine thrust direction
		weapon_hitbox.position.x = 20 if anim.flip_h == false else -20
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
			weapon_hitbox.monitoring = false
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # reset vertical speed when on the floor

extends CharacterBody2D

@export var speed: float = 100.0
@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var gravity: float = 800.0


@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $EnemySprite2
@onready var animhit = $CollisionShape2D
@onready var weapon_hitbox = $RatAttack
@onready var enemy_hitbox = $EnemyHitbox
@export var attack_thrust: float = 100.0  # forward movement during attack
@export var attack_duration: float = 0.3  # time the thrust lasts
	
var state = "idle"
var attack_timer: float = 0.3
var death = false
var max_heath = 1
var health = 1

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	if player == null:
		anim.play("rat_idle")
		velocity.x = 0
		move_and_slide()
		return #
	
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
	anim.play("rat_idle")
	move_and_slide()

func chase(delta):
	var direction = (player.global_position - global_position).normalized()
	anim.flip_h = player.global_position.x < global_position.x
	if player.global_position.x < global_position.x:
		weapon_hitbox.position.x = -27
	else :
		weapon_hitbox.position.x = 0
	
	velocity.x = direction.x * speed
	apply_gravity(delta)
	move_and_slide()
	anim.play("rat_walk")

func attack(delta):
	if attack_timer <= 0:
		# Start attack
		attack_timer = attack_duration
		weapon_hitbox.monitoring = true  # enable hitbox
		anim.play("rat_attack")
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


func _on_rat_attack_body_entered(body: Node2D) -> void:
	if state == "attack" and body.has_method("take_damage"):
		body.take_damage(1)


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

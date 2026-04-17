extends Node

@export var speed = 200.0
var dash_velocity = 220.0
var can_dash = true
var is_dashing = false

@export var gravity_cap = 980
@export var jump_gravity = -320
@export var glide_gravity = 80
@export var threshold = 1

var max_jump_charge = 1

@export var jump_charge = max_jump_charge
@export var dash_charge = 1
var dash_direction
var velocity

var current_glide_gravity = gravity_cap
var glide_timer = 0.0

var glide_mod = 1.7

var motion = Vector2()
var motion_previous = Vector2()

var hit_the_ground = false

func _ready():
	GlobalScript.request_movement_equip_effect.connect(_on_equip_requested)
	GlobalScript.remove_movement_equip_effect.connect(_on_equip_remove)

func _on_equip_requested(type: int, item_name: String):
	if item_name.to_lower() == "jump_boots":
		max_jump_charge = 2
		speed = 200.0
	elif item_name.to_lower() == "dash_boots":
		dash_velocity = 320.0
	elif item_name.to_lower() == "speed_up":
		speed += 40.0
	elif item_name.to_lower() == "glide_up":
		glide_mod = 0.5

func _on_equip_remove(type: int, item_name: String):
	if item_name.to_lower() == "jump_boots":
		max_jump_charge = 1
	elif item_name.to_lower() == "dash_boots":
		dash_velocity = 220.0
	elif item_name.to_lower() == "speed_up":
		speed -= 40.0
	elif item_name.to_lower() == "glide_up":
		glide_mod = 1.7

func basic_movement(delta: float, player: CharacterBody2D,  animated: AnimatedSprite2D) -> void:	
	if player.is_on_floor():
		dash_charge = 1
		jump_charge = max_jump_charge
		glide_timer = 0.0
		current_glide_gravity = glide_gravity
		
		if Input.is_action_just_pressed("jump"):
			player.velocity.y = jump_gravity
	
	else:
		if Input.is_action_just_pressed("jump") and jump_charge > 0:
			jump_charge = jump_charge - 1
			player.velocity.y = jump_gravity

		elif Input.is_action_pressed("jump") and player.velocity.y > 0:
			glide_timer += delta * glide_mod
			
			if glide_timer > threshold:
				current_glide_gravity *= 7
				current_glide_gravity = min(current_glide_gravity, gravity_cap)
			else:
				current_glide_gravity = glide_gravity
		else:
			# Letting go early uses normal gravity
			current_glide_gravity = gravity_cap
		player.velocity.y += current_glide_gravity * delta
	
	if is_dashing:
		execute_dash_logic(player)
		return
	
	var direction := Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("shift") and can_dash:
		dash_start(direction, animated)
		
	if direction:
		player.velocity.x = direction * (speed)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		
func dash_start(dir, animated):
	if not can_dash or dash_charge < 1: 
		return
	
	can_dash = false
	dash_charge = dash_charge - 1
	is_dashing = true
	
	if dir == 0:
		dash_direction = -1 if animated.flip_h else 1
	else:
		dash_direction = dir
	
	$DashDurationTimer.start(0.2) 
	$DashCooldownTimer.start(0.22)

func execute_dash_logic( player: CharacterBody2D):
	player.velocity = Vector2(dash_direction * dash_velocity, 0)
	player.move_and_slide()

func _on_dash_duration_timer_timeout() -> void:
	is_dashing = false

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func handle_scaling(player: CharacterBody2D, animated: AnimatedSprite2D):
	var target_scale_x = 1.0
	var target_scale_y = 1.0

	if not player.is_on_floor():
		hit_the_ground = false
		target_scale_y = remap(abs(player.velocity.y), 0, gravity_cap, 0.95, 1.05)
		target_scale_x = remap(abs(player.velocity.y), 0, gravity_cap, 1.05, 0.95)
	
	if not hit_the_ground and player.is_on_floor():
		hit_the_ground = true
		target_scale_x = remap(abs(motion_previous.y), 0, 800, 1.2, 2.0)
		target_scale_y = remap(abs(motion_previous.y), 0, 800, 0.8, 0.5)

	if is_dashing:
		target_scale_y = target_scale_y - 0.2
		target_scale_x = target_scale_y + 0.2

	animated.scale.x = lerp(animated.scale.x, target_scale_x, 0.5)
	animated.scale.y = lerp(animated.scale.y, target_scale_y, 0.5)
	
	motion_previous = player.velocity

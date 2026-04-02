extends Node

@export var speed = 200.0
var dash_velocity = 1.0
var can_dash = true
var is_dashing = false

@export var gravity_cap = 980
@export var jump_gravity = -320
@export var glide_gravity = 80
@export var threshold = 1

var current_glide_gravity = gravity_cap
var glide_timer = 0.0

var motion = Vector2()
var motion_previous = Vector2()

var hit_the_ground = false

func basic_movement(delta: float, player: CharacterBody2D) -> void:
	if player.is_on_floor():
		glide_timer = 0.0
		current_glide_gravity = glide_gravity
		
		if Input.is_action_just_pressed("jump"):
			player.velocity.y = jump_gravity
		
	else:
		if Input.is_action_pressed("jump") and player.velocity.y > 0:
			glide_timer += delta*1.7
			
			if glide_timer > threshold:
				current_glide_gravity *= 7
				current_glide_gravity = min(current_glide_gravity, gravity_cap)
			else:
				current_glide_gravity = glide_gravity
		else:
			# Letting go early uses normal gravity
			current_glide_gravity = gravity_cap
		player.velocity.y += current_glide_gravity * delta
	
	if Input.is_action_just_pressed("shift") and can_dash:
		dash_start()

	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * (speed * dash_velocity)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		
func dash_start():
	if not can_dash: 
		return
	
	can_dash = false
	is_dashing = true
	dash_velocity = 2
	$DashDurationTimer.start(0.5) 
	$DashCooldownTimer.start(0.6)

func _on_dash_duration_timer_timeout() -> void:
	dash_velocity = 1
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
		target_scale_y = 0.8
		target_scale_x = 1.2

	animated.scale.x = lerp(animated.scale.x, target_scale_x, 0.5)
	animated.scale.y = lerp(animated.scale.y, target_scale_y, 0.5)
	
	motion_previous = player.velocity

extends CharacterBody2D


@export var speed = 200.0
var dash_velocity = 1.0
var can_dash = true
var is_dashing = false

@export var gravity_cap = 980
@export var jump_gravity = -480
@export var glide_gravity = 80
@export var threshold = 1

var current_glide_gravity = gravity_cap
var glide_timer = 0.0

@onready var animatedSprite = $AnimatedSprite2D

var motion = Vector2()
var motion_previous = Vector2()

var hit_the_ground = false


# runs at launch
func _physics_process(delta: float) -> void:
	motion = velocity
	basic_movement(delta)
	handle_animations()
	handle_scaling()
	handle_direction()
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		attack()

func attack():
	$AnimationPlayer.play("Attack")

func handle_animations() -> void:
	if is_on_floor():
		if velocity.x:
			animatedSprite.play("owl_run")
		else:
			animatedSprite.play("owl_idle")
	else:
		if velocity.y < 0:
			animatedSprite.play("owl_jump")
		else:
			animatedSprite.play("owl_fall")

func handle_scaling():
	# Default targets (Normal size)
	var target_scale_x = 1.0
	var target_scale_y = 1.0

	if not is_on_floor():
		hit_the_ground = false
		target_scale_y = remap(abs(velocity.y), 0, gravity_cap, 0.9, 1.1)
		target_scale_x = remap(abs(velocity.y), 0, gravity_cap, 1.1, 0.9)
	
	if not hit_the_ground and is_on_floor():
		hit_the_ground = true
		target_scale_x = remap(abs(motion_previous.y), 0, 1700, 1.2, 2.0)
		target_scale_y = remap(abs(motion_previous.y), 0, 1700, 0.8, 0.5)

	if is_dashing:
		target_scale_y = 0.8
		target_scale_x = 1.2

	animatedSprite.scale.x = lerp(animatedSprite.scale.x, target_scale_x, 0.5)
	animatedSprite.scale.y = lerp(animatedSprite.scale.y, target_scale_y, 0.5)
	
	motion_previous = velocity

func handle_direction() -> void:
	if velocity.x < 0:
		animatedSprite.flip_h = true
	elif velocity.x > 0:
		animatedSprite.flip_h = false

func basic_movement(delta: float) -> void:
	if is_on_floor():
		glide_timer = 0.0
		current_glide_gravity = glide_gravity
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_gravity
		
	else:
		if Input.is_action_pressed("jump") and velocity.y > 0:
			glide_timer += delta*1.7
			
			if glide_timer > threshold:
				current_glide_gravity *= 7
				current_glide_gravity = min(current_glide_gravity, gravity_cap)
			else:
				current_glide_gravity = glide_gravity
		else:
			# Letting go early uses normal gravity
			current_glide_gravity = gravity_cap
		velocity.y += current_glide_gravity * delta
	
	if Input.is_action_just_pressed("shift") and can_dash:
		dash_start()

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * (speed * dash_velocity)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
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

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		#Go to pause menu if Esc key pressed
		get_tree().change_scene_to_file("res://pause_menu.tscn")

func _on_attack_area_entered(area: Area2D) -> void:
	print("Damage")

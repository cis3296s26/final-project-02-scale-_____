extends CharacterBody2D


@export var speed = 200.0
var dash_velocity = 1.0
var can_dash = true

@export var gravity_cap = 980
@export var jump_gravity = -480
@export var glide_gravity = 80
@export var threshold = 1

var current_glide_gravity = gravity_cap
var glide_timer = 0.0
var on_ground = false

var tween: Tween

@onready var animatedSprite = $AnimatedSprite2D

# runs at launch
func _physics_process(delta: float) -> void:
	basic_movement(delta)
	handle_animations()
	handle_direction()
	move_and_slide()

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
			if animatedSprite.animation != "owl_fall":
				animatedSprite.play("owl_fall")

func handle_direction() -> void:
	if velocity.x < 0:
		animatedSprite.flip_h = true
	elif velocity.x > 0:
		animatedSprite.flip_h = false

func basic_movement(delta: float) -> void:
	if is_on_floor():
		glide_timer = 0.0
		current_glide_gravity = glide_gravity
		on_ground = true
		
		if Input.is_action_just_pressed("jump") and on_ground:
			velocity.y = jump_gravity
			on_ground = false
		
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
	
	
	
	dash_velocity = 2
	$DashDurationTimer.start(0.5) 
	$DashCooldownTimer.start(0.6)

func _on_dash_duration_timer_timeout() -> void:
	dash_velocity = 1


func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

# more in-dept player functions
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		#Go to pause menu if Esc key pressed
		get_tree().change_scene_to_file("res://pause_menu.tscn")

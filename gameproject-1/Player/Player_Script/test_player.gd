extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0

@onready var animatedSprite = $AnimatedSprite2D

# runs at launch
func _physics_process(delta: float) -> void:
	basic_movement(delta)
	handle_animations()
	handle_direction()
	move_and_slide()

func handle_animations() -> void:
	if is_on_floor():
		# if velocity:
			# animatedSprite.play("run")
		# else:
			animatedSprite.play("owl_idle")
	else:
		if velocity.y < 0:
			animatedSprite.play("owl_still")
		# else:
		#	animatedSprite.play("fall")

func handle_direction() -> void:
	if velocity.x < 0:
		animatedSprite.flip_h = true
	elif velocity.x > 0:
		animatedSprite.flip_h = false

func basic_movement(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			#Go to pause menu if Esc key pressed
			get_tree().change_scene_to_file("res://pause_menu.tscn");

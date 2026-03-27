extends CharacterBody2D

@export var speed = 275.0
@export var jump_velocity = -400.0

@export var max_health = 3
var current_health = 3
var can_take_damage = true

@onready var animatedSprite = $AnimatedSprite2D
@onready var heart_bar = $"../HeartBar"

func _ready() -> void:
	current_health = max_health
	update_hearts()

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
	if not is_on_floor():
		var gravity = get_gravity()
		if velocity.y > 0:
			gravity *= 0.30
		velocity += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func take_damage(amount: int) -> void:
	if not can_take_damage:
		return

	current_health -= amount

	if current_health < 0:
		current_health = 0

	update_hearts()

	# flash red effect
	animatedSprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.15).timeout
	animatedSprite.modulate = Color(1, 1, 1)

	if current_health == 0:
		get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
		return

	can_take_damage = false
	await get_tree().create_timer(1.0).timeout
	can_take_damage = true

func update_hearts() -> void:
	if heart_bar:
		heart_bar.update_hearts(current_health)

@onready var pause_menu = $CanvasLayer/PauseMenu

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if pause_menu.visible:
			# Resume
			get_tree().paused = false
			pause_menu.visible = false
		else:
			# Pause
			get_tree().paused = true
			#Go to pause menu if Esc key pressed
			pause_menu.visible = true

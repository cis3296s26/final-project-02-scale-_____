extends CharacterBody2D

@onready var movement = $Movement 
@onready var combat = $Combat
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var heart_bar = $"../HeartBar"

@onready var animatedSprite = $AnimatedSprite2D

var coin_count = 0
@onready var coin_label = get_node_or_null("../HeartBar/UIRoot/CoinLabel")

func _ready() -> void:
	GlobalScript.current_health = GlobalScript.max_health
	update_hearts(GlobalScript.current_health)
	update_coin_label()

# runs at launch
func _physics_process(delta: float) -> void:
	movement.basic_movement(delta, self)
	handle_animations()
	movement.handle_scaling(self, animatedSprite)
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
			animatedSprite.play("owl_fall")

func handle_direction() -> void:
	if velocity.x < 0:
		animatedSprite.flip_h = true
	elif velocity.x > 0:
		animatedSprite.flip_h = false

func take_damage(amount: int) -> void:
	if not GlobalScript.can_take_damage:
		return

	GlobalScript.current_health -= amount

	if GlobalScript.current_health < 0:
		GlobalScript.current_health = 0

	update_hearts(GlobalScript.current_health)

	if GlobalScript.current_health == 0:
		get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
		return

	GlobalScript.can_take_damage = false
	await get_tree().create_timer(1.0).timeout
	GlobalScript.can_take_damage = true

func update_hearts(health: int) -> void:
	if heart_bar:
		heart_bar.update_hearts(health)

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

func add_coin() -> void:
	coin_count += 1
	update_coin_label()

func update_coin_label() -> void:
	if coin_label:
		coin_label.text = str(coin_count)

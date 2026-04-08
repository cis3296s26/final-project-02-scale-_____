extends CharacterBody2D

var isAttacking: bool
var is_knocking_back: bool
var knockback = 200

@onready var movement = $Movement 
@onready var combat = $Combat
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var heart_bar = $HeartBar

@onready var animatedSprite = $AnimatedSprite2D

var coin_count = 0
@onready var coin_label = $Player_Bar/UIRoot/CoinLabel

func _ready() -> void:
	GlobalScript.current_health = GlobalScript.max_health
	update_hearts(GlobalScript.current_health)
	update_coin_label()
	$Combat.attack_state_changed.connect(handle_movement_animations)

# runs at launch
func _physics_process(delta: float) -> void:
	if is_knocking_back:
		animatedSprite.play("owl_hurt")
		velocity.y += 980 * delta 
		move_and_slide()
		return
	
	movement.basic_movement(delta, self, animatedSprite)
	handle_direction(isAttacking)
	handle_movement_animations(isAttacking)
	movement.handle_scaling(self, animatedSprite)
	combat.handle_combat(self, animatedSprite)
	move_and_slide()

func handle_movement_animations(state: bool) -> void:
	isAttacking = state
	if isAttacking:
		return
		
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

func handle_direction(state: bool) -> void:
	isAttacking = state
	if isAttacking:
		return
	
	if velocity.x < 0:
		combat.scale.x = -1
		animatedSprite.flip_h = true
	elif velocity.x > 0:
		combat.scale.x = 1
		animatedSprite.flip_h = false

func take_damage(amount: int, weapon_position: Vector2) -> void:
	if not GlobalScript.can_take_damage:
		return
	
	GlobalScript.current_health -= amount

	if GlobalScript.current_health < 0:
		GlobalScript.current_health = 0
	
	apply_knockback(weapon_position)
	
	update_hearts(GlobalScript.current_health)

	if GlobalScript.current_health == 0:
		get_tree().change_scene_to_file("res://scenes/pop-ups/death_screen.tscn")
		return

	GlobalScript.can_take_damage = false
	await get_tree().create_timer(1.0).timeout
	GlobalScript.can_take_damage = true

func apply_knockback(weapon_position: Vector2):
	is_knocking_back = true
	knockback_animation()
	var direction_damage = (global_position - weapon_position).normalized()
	print(direction_damage)
	velocity = Vector2(direction_damage.x * knockback, -200)
	$KnockbackTimer.start(0.2)

func knockback_animation():
	var tween = create_tween().set_loops(3)
	tween.tween_property(animatedSprite, "modulate:a", 0, 0.1)
	tween.tween_property(animatedSprite, "modulate:a", 1, 0.1)

func _on_knockback_timer_timeout() -> void:
	is_knocking_back = false

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
	print("coint", coin_count)
	coin_count += 1
	print("coint", coin_count)
	update_coin_label()

func update_coin_label() -> void:
	print("existing1")
	if coin_label:
		print("existing2")
		coin_label.text = str(coin_count)

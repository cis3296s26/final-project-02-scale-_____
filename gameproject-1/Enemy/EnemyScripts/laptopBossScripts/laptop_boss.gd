extends CharacterBody2D

@export var damage_value = 1
@export var detection_range: float = 250.0
@export var explosion_range: float = 60.0
@export var attack_cooldown: float = 2.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $BossSprite2

# Attack scenes (you must create these)
@export var eclipse_beam: PackedScene
@export var vs_projectile: PackedScene
@export var intel_exp: PackedScene

var state = "idle"
var attack_timer = 0.0
var is_attacking = false

var death = false
var health = 20


func _physics_process(delta):
	if death:
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var distance = global_position.distance_to(player.global_position)

	# Always face player
	anim.flip_h = player.global_position.x < global_position.x

	# Cooldown timer
	if attack_timer > 0:
		attack_timer -= delta
		return

	# Don't interrupt an active attack
	if is_attacking:
		return

	# Decide attack
	if distance <= explosion_range:
		start_explosion_attack()
	elif distance <= detection_range:
		choose_random_attack()

func choose_random_attack():
	var choice = randi() % 2  # 0 or 1
	
	if choice == 0:
		start_beam_attack()
	else:
		start_projectile_attack()

func start_beam_attack():
	is_attacking = true
	anim.play("laptop_beam")

	await get_tree().create_timer(0.5).timeout

	# Spawn orb above enemy
	var orb = eclipse_beam.instantiate()
	get_parent().add_child(orb)
	orb.global_position = global_position + Vector2(0, -40)

	# Tell orb where player is (optional)
	if orb.has_method("set_target"):
		orb.set_target(player)

	await get_tree().create_timer(2.0).timeout

	end_attack()
	
func start_projectile_attack():
	if is_attacking:
		return

	is_attacking = true
	anim.play("laptop_track")

	await get_tree().create_timer(0.3).timeout

	if player == null:
		end_attack()
		return

	var proj = vs_projectile.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position

	proj.set_target(player)

	var dir = (player.global_position - global_position).normalized()
	proj.velocity = dir * proj.speed
	proj.rotation = dir.angle()

	await get_tree().process_frame  # ensure initialization finishes

	end_attack()

func start_explosion_attack():
	is_attacking = true
	anim.play("laptop_burst")

	await get_tree().create_timer(0.5).timeout

	var explosion = intel_exp.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	end_attack()


# =========================
# END ATTACK
# =========================
func end_attack():
	is_attacking = false
	attack_timer = attack_cooldown
	anim.play("laptop_idle")


# =========================
# DAMAGE HANDLING
# =========================
func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	if death:
		return

	if area.is_in_group("attack"):
		health -= 1
		anim.play("laptop_hit")

		if health <= 0:
			death = true
			anim.play("laptop_death")
			await anim.animation_finished
			queue_free()

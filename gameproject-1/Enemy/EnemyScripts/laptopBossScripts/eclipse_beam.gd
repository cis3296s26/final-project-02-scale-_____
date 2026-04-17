extends Node2D

@onready var anim: AnimatedSprite2D = $BeamSprite
@onready var hitbox: Area2D = $BeamAttack   # Long collision shape matching beam

var target: Node2D = null
var locked_direction: Vector2 = Vector2.RIGHT

@export var damage_value: int = 1

# Timing (tweak to match animations)
@export var charge_time: float = 0.7
@export var point_time: float = 0.3
@export var beam_time: float = 1.0
@export var finish_time: float = 0.5


func _ready():
	hitbox.monitoring = false
	start_sequence()


func set_target(p):
	target = p


func start_sequence():
	await charge_phase()
	await point_phase()
	await beam_phase()
	await finish_phase()
	queue_free()


# =========================
# CHARGE (tracks player)
# =========================
func charge_phase():
	anim.play("eclipse_charge")

	var timer := 0.0
	while timer < charge_time:
		if target:
			var dir = (target.global_position - global_position).normalized()
			rotation = dir.angle()
		timer += get_process_delta_time()
		await get_tree().process_frame


# =========================
# POINT (locks direction)
# =========================
func point_phase():
	anim.play("eclipse_point")

	# Lock direction at end of tracking
	locked_direction = Vector2.RIGHT.rotated(rotation)

	await get_tree().create_timer(point_time).timeout


# =========================
# BEAM (fires)
# =========================
func beam_phase():
	anim.play("eclipse_beam")

	# Enable damage
	hitbox.monitoring = true

	await get_tree().create_timer(beam_time).timeout

	hitbox.monitoring = false


# =========================
# FINISH (power down)
# =========================
func finish_phase():
	anim.play("eclipse_finish")
	await get_tree().create_timer(finish_time).timeout


# =========================
# DAMAGE
# =========================
func _on_beam_attack_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage_value, global_position)

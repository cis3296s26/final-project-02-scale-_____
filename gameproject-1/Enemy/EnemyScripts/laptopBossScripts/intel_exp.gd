extends Area2D

@onready var anim: AnimatedSprite2D = $ExplosionSprite
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var damage_value: int = 3
@export var charge_time: float = 0.6
@export var active_time: float = 0.2

var exploded = false


func _ready():
	start_explosion()

func start_explosion():
	await charge_phase()
	await explosion_phase()
	queue_free()

func charge_phase():
	anim.play("intelExp_charge")
	collision.disabled = true
	
	await get_tree().create_timer(charge_time).timeout

func explosion_phase():
	if exploded:
		return
	
	exploded = true
	
	anim.play("intelExp_active")
	collision.disabled = false
	
	# Damage check happens instantly on activation
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage_value, global_position)
	
	await get_tree().create_timer(active_time).timeout


# =========================
# OPTIONAL: SAFETY CLEANUP
# =========================
func _on_body_entered(body):
	if not exploded:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage_value, global_position)

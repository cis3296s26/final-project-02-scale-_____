extends Area2D

@onready var anim: AnimatedSprite2D = $ProjectileSprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var target: Node2D = null
var velocity: Vector2 = Vector2.ZERO

@export var speed: float = 75.0
@export var lifetime: float = 2.5
@export var damage_value: int = 1

var is_active = false
var is_finished = false
var timer = 0.0


func _ready():
	start_spawn()

func set_target(p):
	target = p

func start_spawn():
	anim.play("vs_spawn")

	collision.set_deferred("disabled", true)

	# small delay
	await get_tree().create_timer(0.2).timeout

	collision.set_deferred("disabled", false)

	start_active()

func start_active():
	anim.play("vs_active")

	is_active = true
	timer = 0.0

	if target:
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed


func _physics_process(delta):
	if not is_active or is_finished:
		return

	timer += delta

	# TRACK TARGET
	if target:
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed
		rotation = velocity.angle()

	# MOVE
	global_position += velocity * delta

	# LIFETIME END
	if timer >= lifetime:
		start_finish()

func start_finish():
	if is_finished:
		return

	is_finished = true
	is_active = false

	collision.set_deferred("disabled", true)

	velocity = Vector2.ZERO

	anim.play("vs_finish")

func _on_body_entered(body):
	if is_finished or not is_active:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage_value, global_position)

	start_finish()


func _on_projectile_sprite_animation_finished() -> void:
	if anim.animation == "vs_finish":
		queue_free()

extends CharacterBody2D

var death = false
var max_heath = 3
var health = 3

@onready var animatedSprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	if not death and $AnimatedSprite2D.animation != "dummy_hit":
		$AnimatedSprite2D.play("dummy_idle")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if death:
		$CollisionShape2D.set_deferred("disabled", true)
		return
	
	if area.is_in_group("attack"):
		health = health - 1
		print("Hit! Health is now: ", health)
		$AnimatedSprite2D.play("dummy_hit")
		if health <= 0:
			print("DEATH")
			death = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "dummy_hit":
		if death:
			print("Play Sprite")
			$AnimatedSprite2D.play("dummy_death")
		else:
			$AnimatedSprite2D.play("dummy_idle")

extends Node2D

@onready var player = $Player
@onready var spawn_point = $Spawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalScript.levelcom >= 5:
		player.global_position = spawn_point.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

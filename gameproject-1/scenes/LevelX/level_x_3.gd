extends Node2D
@onready var enemy = $laptop_boss
@onready var transition_area = $TransitionCollision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalScript.current_level_path = scene_file_path


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_laptop_boss_died() -> void:
	transition_area.monitoring = true
	transition_area.visible = true
	

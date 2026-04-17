extends Control

@onready var resume_button = $Panel2/VBoxContainer/Resume
@onready var main_menu_button = $Panel2/VBoxContainer/"Main Menu"
@onready var controls_button = $Panel2/VBoxContainer/Controls

var controls_menu_scene = preload("res://scenes/pop-ups/controls_menu.tscn")
var controls_menu_instance = null

func _ready():
	visible = false
	set_process_input(true)
	set_process_unhandled_input(true)

	if resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.disconnect(_on_resume_pressed)
	if main_menu_button.pressed.is_connected(_on_main_menu_pressed):
		main_menu_button.pressed.disconnect(_on_main_menu_pressed)
	if controls_button.pressed.is_connected(_on_controls_pressed):
		controls_button.pressed.disconnect(_on_controls_pressed)

	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	controls_button.pressed.connect(_on_controls_pressed)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if controls_menu_instance != null and is_instance_valid(controls_menu_instance):
				controls_menu_instance.queue_free()
				controls_menu_instance = null
				visible = true
			else:
				visible = false
				get_tree().paused = false

func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_main_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	GlobalScript.reset_game()
	get_tree().change_scene_to_file("res://scenes/pop-ups/main_menu.tscn")

func _on_controls_pressed() -> void:
	visible = false

	if controls_menu_instance == null or not is_instance_valid(controls_menu_instance):
		controls_menu_instance = controls_menu_scene.instantiate()
		controls_menu_instance.pause_menu = self
		get_parent().add_child(controls_menu_instance)

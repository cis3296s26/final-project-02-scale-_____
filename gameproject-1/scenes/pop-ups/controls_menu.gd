extends Control

const SAVE_PATH = "user://keybinds.cfg"

@onready var left_button = $Panel/LeftButton
@onready var right_button = $Panel/RightButton
@onready var jump_button = $Panel/JumpButton
@onready var shift_button = $Panel/ShiftButton
@onready var attack_button = $Panel/AttackButton
@onready var drop_button = $Panel/DropButton
@onready var reset_button = $Panel/ResetButton
@onready var back_button = $Panel/BackButton

var waiting_for_input := false
var action_to_remap := ""
var pause_menu = null

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	load_keybinds()
	update_buttons()

	if left_button.pressed.is_connected(_on_left_pressed):
		left_button.pressed.disconnect(_on_left_pressed)
	if right_button.pressed.is_connected(_on_right_pressed):
		right_button.pressed.disconnect(_on_right_pressed)
	if jump_button.pressed.is_connected(_on_jump_pressed):
		jump_button.pressed.disconnect(_on_jump_pressed)
	if shift_button.pressed.is_connected(_on_shift_pressed):
		shift_button.pressed.disconnect(_on_shift_pressed)
	if attack_button.pressed.is_connected(_on_attack_pressed):
		attack_button.pressed.disconnect(_on_attack_pressed)
	if drop_button.pressed.is_connected(_on_drop_pressed):
		drop_button.pressed.disconnect(_on_drop_pressed)
	if reset_button.pressed.is_connected(_on_reset_pressed):
		reset_button.pressed.disconnect(_on_reset_pressed)
	if back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.disconnect(_on_back_pressed)

	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)
	jump_button.pressed.connect(_on_jump_pressed)
	shift_button.pressed.connect(_on_shift_pressed)
	attack_button.pressed.connect(_on_attack_pressed)
	drop_button.pressed.connect(_on_drop_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_make_panel_smaller()

func _make_panel_smaller():
	var panel = $Panel
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(320, 420)
	panel.size = Vector2(320, 420)
	panel.position = (get_viewport_rect().size - panel.size) / 2.0

func _on_left_pressed():
	_on_remap_pressed("left")

func _on_right_pressed():
	_on_remap_pressed("right")

func _on_jump_pressed():
	_on_remap_pressed("jump")

func _on_shift_pressed():
	_on_remap_pressed("shift")

func _on_attack_pressed():
	_on_remap_pressed("attack")

func _on_drop_pressed():
	_on_remap_pressed("drop")

func _on_remap_pressed(action_name: String):
	waiting_for_input = true
	action_to_remap = action_name
	var button = get_button_for_action(action_name)
	if button:
		button.text = "Press a key..."

func _input(event):
	if not waiting_for_input:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		remap_action(action_to_remap, event)
		waiting_for_input = false
		action_to_remap = ""
		update_buttons()
		get_viewport().set_input_as_handled()

func remap_action(action_name: String, event: InputEventKey):
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		for old_event in events:
			if old_event is InputEventKey and old_event.physical_keycode == event.physical_keycode:
				InputMap.action_erase_event(action, old_event)

	var selected_events = InputMap.action_get_events(action_name)
	for selected_event in selected_events:
		if selected_event is InputEventKey:
			InputMap.action_erase_event(action_name, selected_event)

	var new_event = InputEventKey.new()
	new_event.physical_keycode = event.physical_keycode
	InputMap.action_add_event(action_name, new_event)

	save_keybinds()

func update_buttons():
	left_button.text = "Left: " + get_action_text("left")
	right_button.text = "Right: " + get_action_text("right")
	jump_button.text = "Jump: " + get_action_text("jump")
	shift_button.text = "Shift: " + get_action_text("shift")
	attack_button.text = "Attack: " + get_action_text("attack")
	drop_button.text = "Drop: " + get_action_text("drop")

func get_action_text(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return "Unbound"

func get_button_for_action(action_name: String) -> Button:
	match action_name:
		"left":
			return left_button
		"right":
			return right_button
		"jump":
			return jump_button
		"shift":
			return shift_button
		"attack":
			return attack_button
		"drop":
			return drop_button
		_:
			return null

func _on_reset_pressed():
	reset_action("left", KEY_A)
	reset_action("right", KEY_D)
	reset_action("jump", KEY_W)
	reset_action("shift", KEY_SHIFT)
	reset_action("attack", KEY_Z)
	reset_action("drop", KEY_C)

	save_keybinds()
	update_buttons()

func reset_action(action_name: String, keycode: int):
	var old_events = InputMap.action_get_events(action_name)
	for old_event in old_events:
		if old_event is InputEventKey:
			InputMap.action_erase_event(action_name, old_event)

	var new_event = InputEventKey.new()
	new_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, new_event)

func save_keybinds():
	var config = ConfigFile.new()
	save_action_key(config, "left")
	save_action_key(config, "right")
	save_action_key(config, "jump")
	save_action_key(config, "shift")
	save_action_key(config, "attack")
	save_action_key(config, "drop")
	config.save(SAVE_PATH)

func save_action_key(config: ConfigFile, action_name: String):
	var events = InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventKey:
			config.set_value("keybinds", action_name, event.physical_keycode)
			return

func load_keybinds():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return

	load_action_key(config, "left")
	load_action_key(config, "right")
	load_action_key(config, "jump")
	load_action_key(config, "shift")
	load_action_key(config, "attack")
	load_action_key(config, "drop")

func load_action_key(config: ConfigFile, action_name: String):
	if not config.has_section_key("keybinds", action_name):
		return

	var keycode = config.get_value("keybinds", action_name)

	var old_events = InputMap.action_get_events(action_name)
	for old_event in old_events:
		if old_event is InputEventKey:
			InputMap.action_erase_event(action_name, old_event)

	var event = InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)

func _on_back_pressed():
	if pause_menu != null:
		pause_menu.controls_menu_instance = null
		pause_menu.visible = true
	queue_free()

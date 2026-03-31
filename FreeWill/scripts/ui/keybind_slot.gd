class_name Keybind extends Node2D

@export var action_name: String
@export var action_one: Button
@export var action_two: Button

var awaiting_input: Button = null

func _ready() -> void:
	update_labels()
	if action_one:
		action_one.pressed.connect(_on_action_one_pressed)
	
	if action_two:
		action_two.pressed.connect(_on_action_two_pressed)

func update_labels() -> void:
	if not InputMap.has_action(action_name):
		assert(false, "THAT ACTION %s DOES NOT EXIST!!!" % action_name)
		push_error("Action '%s' does not exist in InputMap" % action_name)
		return
	
	var events := InputMap.action_get_events(action_name)
	
	if action_one:
		if events.size() > 0:
			action_one.text = event_to_string(events[0])
		else:
			action_one.text = "None"
	
	if action_two:
		if events.size() > 1:
			action_two.text = event_to_string(events[1])
		else:
			action_two.text = "None"

func event_to_string(event: InputEvent) -> String:
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		return "Mouse %d" % event.button_index
	elif event is InputEventJoypadButton:
		return "Joy %d" % event.button_index
	else:
		return str(event)

func _on_action_one_pressed() -> void:
	start_rebind(action_one, 0)

func _on_action_two_pressed() -> void:
	start_rebind(action_two, 1)

func start_rebind(button: Button, index: int) -> void:
	awaiting_input = button
	button.text = "..."
	button.set_meta("rebind_index", index)
	#guard against double click because i keep running into that issue
	button.disabled = true

func _input(event: InputEvent) -> void:
	if awaiting_input == null:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		rebind_action(event, awaiting_input.get_meta("rebind_index"))
	elif event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()
		rebind_action(event, awaiting_input.get_meta("rebind_index"))

func rebind_action(new_event: InputEvent, index: int) -> void:
	var events := InputMap.action_get_events(action_name)
	
	if index < events.size():
		InputMap.action_erase_event(action_name, events[index])
	
	InputMap.action_add_event(action_name, new_event)
	
	if awaiting_input:
		awaiting_input.disabled = false
	awaiting_input = null
	
	update_labels()

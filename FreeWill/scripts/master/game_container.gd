class_name GameContainer extends Control

var _paused: bool = false

var promise: Promise
var game: Node

@export var control: PauseMenuButtonsHandler
@export var blur_drive: BlurDrive
@export var pause_menu: CanvasLayer
@export var lateral_bars: LateralBars
@export var options_dock: Control
@export var loading_shit: LoadingShit
@export var manual: Manual

func _ready() -> void:
	_wire_up_signals()

func _wire_up_signals() -> void:
	Dialogic.signal_event.connect(_summon_manual, CONNECT_ONE_SHOT)
	manual.get_out.connect(kill_the_fucking_manual_im_going_to_go_insane)
	EventBus.change_game_container_to.connect(_on_game_container_change_request)
	control.resume.connect(_on_resume_clicked)
	control.options.connect(_on_options_clicked)
	control.retry.connect(retry)
	control.toggle_fullscreen.connect(_on_toggle_fullscreen)
	loading_shit.finished.connect(_on_loading_shit_finished)

func _on_toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func retry() -> void:
	var scene := get_current_game_scene()
	if scene is not MissonHandler: return
	
	scene.current_wave = game.current_wave
	#this actually advances a wave  so gotta decrement by 1 BUT DONT DECREMENT IF THE PLAYER DIES DURING STARTING DIALOG
	if game.current_wave > 0 :
		scene.current_wave -= 1
	EventBus.change_game_container_to.emit(scene)
	unpause_game()

func get_current_game_scene() -> Node:
	return load(game.scene_file_path).instantiate() 

func kill_the_fucking_manual_im_going_to_go_insane() -> void:
	unpause_game(false)

func _summon_manual(argument: String) -> void:
	if argument == "manual_time":
		pause_game(false)

func _on_loading_shit_finished() -> void:
	loading_shit.queue_free()
	var actual_factual_main_game_intro_sequence := preload("res://scenes/missions/intro_sequence.tscn")\
		.instantiate() as Intro
	EventBus.change_game_container_to.emit(actual_factual_main_game_intro_sequence)

func _on_game_container_change_request(node_to_change_to: Node) -> void:
	if game: game.queue_free()
	add_child(node_to_change_to)

	game = node_to_change_to
	move_child(game, 0)

func reset_promise(signals: Array[Signal] = []) -> void:
	if promise: promise.deny()
	promise = Promise.from_signal_arr(signals).all()

func _on_resume_clicked() -> void:
	unpause_game()

func _on_options_clicked() -> void:
	options_dock.add_child(Registry.create_options_menu())

func pause_game(show_menu := true) -> void:
	if Dialogic.current_timeline: Dialogic.paused = true
	reset_promise()
	if show_menu: 
		pause_menu.show()
		control.cascade_in()
	else:
		manual.appear()
	game.process_mode = Node.PROCESS_MODE_DISABLED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	lateral_bars.scroll_in()
	blur_drive.blur()
	_paused = true

func unpause_game(unroll_menu := true) -> void:
	if Dialogic.current_timeline: Dialogic.paused = false
	blur_drive.unblur()
	lateral_bars.scroll_out()
	
	if unroll_menu:
		control.cascade_out()
		reset_promise([control.cascade_out_chain_finished, blur_drive.t.finished, lateral_bars.t.finished])
		promise.resolved.connect(_on_game_unpaused, CONNECT_ONE_SHOT)
	else:
		manual.disappear()
		reset_promise([blur_drive.t.finished, lateral_bars.t.finished])
		promise.resolved.connect(_unroll_manual, CONNECT_ONE_SHOT)

func _unroll_manual(_res: Variant) -> void:
	_on_game_unpaused(_res, false)

func _on_game_unpaused(_res: Variant, _without_manual := true) -> void:
	_paused = false
	pause_menu.hide()
	game.process_mode = Node.PROCESS_MODE_INHERIT
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if manual.on_screen: return
		if _paused: unpause_game()
		else: pause_game()
	
	if Input.is_action_just_pressed("manual"):
		if not _paused:
			if not manual.on_screen: pause_game(false)
			else: unpause_game(false)

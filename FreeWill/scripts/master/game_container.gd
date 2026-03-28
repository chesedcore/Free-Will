class_name GameContainer extends Control

var _paused: bool = false

var promise: Promise

@export var control: PauseMenuButtonsHandler
@export var main_game: StageHandler
@export var blur_drive: BlurDrive
@export var pause_menu: CanvasLayer
@export var lateral_bars: LateralBars

func _ready() -> void:
	_wire_up_signals()

func _wire_up_signals() -> void:
	control.resume.connect(_on_resume_clicked)

func reset_promise(signals: Array[Signal] = []) -> void:
	if promise: promise.deny()
	promise = Promise.from_signal_arr(signals).all() 

func _on_resume_clicked() -> void:
	unpause_game()

func pause_game() -> void:
	reset_promise()
	pause_menu.show()
	main_game.process_mode = Node.PROCESS_MODE_DISABLED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	control.cascade_in()
	lateral_bars.scroll_in()
	blur_drive.blur()
	_paused = true

func unpause_game() -> void:
	control.cascade_out()
	blur_drive.unblur()
	lateral_bars.scroll_out()
	reset_promise([control.cascade_out_chain_finished, blur_drive.t.finished, lateral_bars.t.finished])
	promise.resolved.connect(_on_game_unpaused, CONNECT_ONE_SHOT)

func _on_game_unpaused(_res: Variant) -> void:
	_paused = false
	pause_menu.hide()
	main_game.process_mode = Node.PROCESS_MODE_INHERIT
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if _paused: unpause_game()
		else: pause_game()

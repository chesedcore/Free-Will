class_name GameContainer extends Control

##you were here, trying to build a pause menu.

@export var control: PauseMenuButtonsHandler
@export var main_game: StageHandler
@export var blur_drive: BlurDrive

func pause_game() -> void:
	main_game.process_mode = Node.PROCESS_MODE_DISABLED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	control.cascade_in()
	blur_drive.blur()

func unpause_game() -> void:
	main_game.process_mode = Node.PROCESS_MODE_INHERIT
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	control.cascade_out()
	blur_drive.unblur()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		pause_game()
	elif Input.is_action_just_pressed("ui_up"):
		unpause_game()

class_name PauseMenuButtonsHandler extends CascadeV2

@export var resume_button: PauseMenuButton
@export var options_button: PauseMenuButton
@export var retry_button: PauseMenuButton
@export var toggle_button: PauseMenuButton

signal resume
signal options
signal retry
signal toggle_fullscreen

func _ready() -> void:
	super()
	_wire_up_signals()

func _wire_up_signals() -> void:
	resume_button.clicked.connect(resume.emit)
	options_button.clicked.connect(options.emit)
	retry_button.clicked.connect(retry.emit)
	toggle_button.clicked.connect(toggle_fullscreen.emit)

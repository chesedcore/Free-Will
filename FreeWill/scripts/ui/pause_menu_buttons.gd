class_name PauseMenuButtonsHandler extends CascadeV2

@export var resume_button: PauseMenuButton
@export var options_button: PauseMenuButton
@export var menu_button: PauseMenuButton

signal resume
signal options
signal menu

func _ready() -> void:
	super()
	_wire_up_signals()

func _wire_up_signals() -> void:
	resume_button.clicked.connect(resume.emit)
	options_button.clicked.connect(options.emit)
	menu_button.clicked.connect(menu.emit)

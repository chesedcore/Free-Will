class_name MainMenu extends Control

@export var start_button: PauseMenuButton
@export var options_button: PauseMenuButton
@export var options_dock: Control
@export var cascade: Cascade
@export var fade_out: ColorRect

signal start_game

func _ready() -> void:
	_wire_up_signals()

func _wire_up_signals() -> void:
	start_button.clicked.connect(_on_start_button_clicked)
	options_button.clicked.connect(_on_options_button_clicked)

func _on_start_button_clicked() -> void:
	create_tween().tween_property(fade_out, "modulate", Color.WHITE, 0.5)
	cascade.cascade_out()
	cascade.cascade_finished.connect(_on_cascade_finished, CONNECT_ONE_SHOT)

func _on_cascade_finished(fade: Cascade.FADE) -> void:
	if not fade == Cascade.FADE.FADE_OUT: return
	start_game.emit()

func _on_options_button_clicked() -> void:
	var options_menu := Registry.create_options_menu()
	options_dock.add_child(options_menu)

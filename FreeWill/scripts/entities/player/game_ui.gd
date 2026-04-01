class_name GameUI extends CanvasLayer

@export var health_bar: TextureProgressBar
@onready var tank: PlayerTank = owner
@export var cool_stuff: Control

func _wire_up_signals() -> void:
	EventBus.whoa_this_happened.connect(_on_shit_happened)

func _ready() -> void:
	_wire_up_signals()

func _process(_delta: float) -> void:
	health_display_update()


func health_display_update() -> void:
	health_bar.value = tank.health
	health_bar.max_value = tank.MAX_HEALTH

func _on_shit_happened(string: String) -> void:
	var label := Registry.create_cool_label()
	label.text = "[shake]"+string
	add_cool_label(label)

func get_random_global_point(ctrl: Control) -> Vector2:
	var local_point := Vector2(
		randf_range(0.0, ctrl.size.x),
		randf_range(0.0, ctrl.size.y)
	)
	return ctrl.get_global_position() + local_point

func get_random_rotation_degrees() -> float:
	return randf_range(-30, 30)

func get_random_colour() -> Color:
	return Color(
		randf_range(0, 1),
		randf_range(0, 1),
		randf_range(0, 1)
	)

func add_cool_label(label: RichTextLabel) -> void:
	cool_stuff.add_child(label)
	label.add_theme_color_override("font_outline_color", get_random_colour())
	label.rotation_degrees = get_random_rotation_degrees()
	label.global_position = get_random_global_point(cool_stuff)

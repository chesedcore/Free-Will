class_name StyleDisplay extends Control

signal style_gained(amount: int)
signal style_lost(amount: int)

const STYLE_RESET_TIME: float = 5.0

@export var test_rank_label: Label
@export var test_points_label: Label
@export var style_loss_time_bar: TextureProgressBar

var style_points: int = 0
var style_time: float = 3.0


func _ready() -> void:
	return
	test_points_label.text = "points: %s" % [style_points]
	style_loss_time_bar.max_value = STYLE_RESET_TIME


func _process(delta: float) -> void:
	return
	visible = (style_time > 0.0)
	style_time_update(delta)


func cool_shit(shit: CoolShit.Shit, points: int) -> void:
	# TEMPORARY
	match shit:
		CoolShit.Shit.PARRY:
			print("PARRIED")
		CoolShit.Shit.DODGE:
			print("DODGED")

	style_points += points
	style_time = STYLE_RESET_TIME
	style_gained.emit(points)

	display_update()


func lame_shit(points_to_remove: int) -> void:
	style_points -= points_to_remove
	style_time *= 0.5
	style_lost.emit(points_to_remove)
	display_update()


func display_update() -> void:
	return
	test_points_label.text = "points: %s" % [style_points]


func style_time_update(delta: float) -> void:
	if (style_time <= 0.0):
		return

	style_time -= delta
	style_loss_time_bar.value = style_time

	if (style_time <= 0.0):
		reset_style()


func reset_style() -> void:
	style_points = 0

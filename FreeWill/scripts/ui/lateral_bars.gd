class_name LateralBars extends Control

@export var bar_left: ColorRect
@export var bar_right: ColorRect
@export var tween_time: float = 0.3

var _original_positions: Dictionary[ColorRect, Vector2]

func _ready() -> void:
	_record_positions()

func _record_positions() -> void:
	for bar: ColorRect in [bar_left, bar_right]:
		assert(bar, "That bar isn't valid!")
		_original_positions[bar] = bar.position

var t: Tween

func scroll_in() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	var left_start := _original_positions[bar_left]
	var right_start := _original_positions[bar_right]

	t.tween_property(
		bar_left,
		"position:x",
		left_start.x + bar_left.size.x,
		tween_time
	)

	t.parallel().tween_property(
		bar_right,
		"position:x",
		right_start.x - bar_right.size.x,
		tween_time
	)

func scroll_out() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	var left_start := _original_positions[bar_left]
	var right_start := _original_positions[bar_right]

	t.tween_property(
		bar_left,
		"position:x",
		left_start.x,
		tween_time
	)

	t.parallel().tween_property(
		bar_right,
		"position:x",
		right_start.x,
		tween_time
	)

class_name LateralBars extends Control

@export var bar_left: ColorRect
@export var bar_right: ColorRect
@export var tween_time: float = 0.3

var _original_positions: Dictionary[ColorRect, Vector2]

func _ready() -> void:
	_record_positions()
	_scroll_in()

func _record_positions() -> void:
	for bar: ColorRect in [bar_left, bar_right]:
		assert(bar, "That bar isn't valid!")
		_original_positions[bar] = bar.position

var t: Tween

func _scroll_in() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(
		bar_left, 
		"position:x", 
		bar_left.position.x + bar_left.size.x, 
		tween_time
	)
	t.parallel().tween_property(
		bar_right,
		"position:x",
		bar_right.position.x - bar_right.size.x,
		tween_time
	)

func _scroll_out() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(
		bar_left,
		"position:x",
		bar_left.position.x - bar_left.size.x,
		tween_time
	)
	t.parallel().tween_property(
		bar_right,
		"position:x",
		bar_right.position.x + bar_right.size.x,
		tween_time
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	

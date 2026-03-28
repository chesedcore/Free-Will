class_name PauseMenuButton extends RichTextLabel

const ZERO_POINT_THREE = 0.45

@export var undershadow_text: RichTextLabel
@export var corresponding_marquee: Marquee
@onready var original_text := self.text
var t: Tween

func _wire_up_signals() -> void:
	mouse_entered.connect(highlight_in)
	mouse_exited.connect(highlight_out)

func _ready() -> void:
	_wire_up_signals()

func reset_tween() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)

func highlight_in() -> void:
	reset_tween()
	t.tween_property(get_theme_font("normal_font"), "spacing_glyph", 10, ZERO_POINT_THREE)
	t.tween_property(undershadow_text.get_theme_font("normal_font"), "spacing_glyph", 11, ZERO_POINT_THREE)
	corresponding_marquee.appear()
	self.text = "[shake]"+original_text

func highlight_out() -> void:
	reset_tween()
	t.tween_property(get_theme_font("normal_font"), "spacing_glyph", 0, ZERO_POINT_THREE)
	t.tween_property(undershadow_text.get_theme_font("normal_font"), "spacing_glyph", 0, ZERO_POINT_THREE)
	corresponding_marquee.disappear()
	self.text = original_text

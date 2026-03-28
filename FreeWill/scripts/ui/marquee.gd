class_name Marquee extends ColorRect

var t: Tween

func _ready() -> void:
	self.scale.y = 0

func reset_tween() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)

func appear() -> void:
	reset_tween()
	t.tween_property(self, "scale:y", 1.0, 0.4)

func disappear() -> void:
	reset_tween()
	t.tween_property(self, "scale:y", 0, 0.4)

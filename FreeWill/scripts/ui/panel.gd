class_name OptionsPanel extends Control

var t: Tween

func reset_tween() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)

func pop_out() -> void:
	reset_tween()
	t.tween_property(self, "scale:y", 1.0, 0.4)

func pop_in() -> void:
	reset_tween()
	t.tween_property(self, "scale:y", 0.0, 0.4)

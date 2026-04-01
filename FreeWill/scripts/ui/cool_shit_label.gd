class_name CoolShitLabel extends RichTextLabel

func _ready() -> void:
	scale = Vector2.ONE * 3
	modulate = Color.TRANSPARENT
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE, 0.3)
	t.tween_property(self, "modulate", Color.WHITE, 0.3)
	t.finished.connect(_disappear)

func _disappear() -> void:
	await get_tree().create_timer(1).timeout
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	t.finished.connect(self.queue_free)

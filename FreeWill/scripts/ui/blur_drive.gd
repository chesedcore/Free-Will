class_name BlurDrive extends ColorRect

@onready var mat: ShaderMaterial = self.material

var t: Tween

func reset_tween() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func unblur() -> void:
	reset_tween()
	t.tween_property(self.mat, "shader_parameter/samples",  1, 0.3)

func blur() -> void:
	reset_tween()
	t.tween_property(self.mat, "shader_parameter/samples", 15, 0.3)

class_name ShakeCamera extends Camera3D


var _shake_time: float = 0.0


func _process(delta: float) -> void:
	if (_shake_time <= 0.0):
		return

	_shake_time -= delta


func trigger_shake(power: float, time: float = 0.25) -> void:
	pass

class_name Shaker
extends Node3D

@export var shake_amp: float = 1
@export var noise_speed: float = 25.0
@export var decay_rate: float = 1.8
@export var return_speed: float = 12.0

var target: Node3D
var _initial_position: Vector3 = Vector3.ZERO

var _trauma: float = 0.0
var _time: float = 0.0

var _noise := FastNoiseLite.new()


func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = 1.0


func set_target(p_target: Node3D) -> void:
	target = p_target
	if target:
		_initial_position = target.position


func shake(amount: float = 0.5) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _process(delta: float) -> void:
	if not target:
		return
	
	_time += delta * noise_speed
	
	if _trauma > 0.0:
		_update_shake(delta)
	else:
		_update_return(delta)


func _update_shake(delta: float) -> void:
	_trauma = maxf(_trauma - decay_rate * delta, 0.0)
	
	var intensity: float = _trauma * _trauma
	
	var offset := Vector3(
		_noise.get_noise_1d(_time),
		_noise.get_noise_1d(_time + 100.0),
		_noise.get_noise_1d(_time + 200.0)
	) * shake_amp * intensity
	
	target.position = _initial_position + offset


func _update_return(delta: float) -> void:
	target.position = target.position.lerp(_initial_position, delta * return_speed)

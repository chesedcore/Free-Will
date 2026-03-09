extends ColorRect

const SCALE = 0.01
const MIN_TANK_SPEED: float = 90.0
const LERP_SPEED: float = 2.0

var shader_value: float = 0.0

@onready var tank: PlayerTank = owner
@onready var shader_mat: ShaderMaterial = material as ShaderMaterial


func _process(delta: float) -> void:
	speed_lines_update(delta)


func speed_lines_update(delta: float) -> void:
	# Bubba: to prevent the speed lines from ALWAYS being visible, we only show
	# them if the player is moving exceptionally fast.
	if (tank.linear_velocity.length() > MIN_TANK_SPEED):
		shader_value = lerpf(
			shader_value,
			tank.linear_velocity.length() * SCALE,
			LERP_SPEED * delta)
	else:
		shader_value = lerpf(
			shader_value,
			0.0,
			LERP_SPEED * delta)

	shader_mat.set_shader_parameter("intensity", shader_value)

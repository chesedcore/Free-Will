extends ColorRect

const SCALE = 0.01
const MIN_TANK_SPEED: float = 90.0
const LERP_SPEED: float = 2.0

var shader_value: float = 0.0

@onready var tank: PlayerTank = owner
@onready var shader_mat: ShaderMaterial = material as ShaderMaterial
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	speed_lines_update(delta)

func speed_lines_update(delta: float) -> void:
	# Bubba: to prevent the speed lines from ALWAYS being visible, we only show
	# them if the player is moving exceptionally fast.
	var speed := tank.linear_velocity.length()
	
	if speed > MIN_TANK_SPEED:
		shader_value = lerpf(
			shader_value,
			speed * SCALE,
			LERP_SPEED * delta)
	else:
		shader_value = lerpf(
			shader_value,
			0.0,
			LERP_SPEED * delta)
	
	shader_mat.set_shader_parameter("intensity", shader_value)
	
	if speed > 0.1:
		var cam_transform := camera.global_transform
		var velocity_in_cam_space := cam_transform.basis.inverse() * tank.linear_velocity
		
		var screen_velocity := Vector2(velocity_in_cam_space.x, -velocity_in_cam_space.z)
		screen_velocity = screen_velocity.normalized()
		
		#flip because y is up in 3d space
		screen_velocity.y = -screen_velocity.y
		
		shader_mat.set_shader_parameter("movement_direction", screen_velocity)
		
		#determine radial/dir blend
		var forward_component := absf(velocity_in_cam_space.z)
		var lateral_component := absf(velocity_in_cam_space.x)
		var total := forward_component + lateral_component
		
		var radial_amount := forward_component / total if total > 0.0 else 0.0
		shader_mat.set_shader_parameter("radial_blend", radial_amount)
		
		var is_backward := velocity_in_cam_space.z > 0
		shader_mat.set_shader_parameter("flow_speed", -0.5 if is_backward else 0.5)

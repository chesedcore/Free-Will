class_name CameraGimbal extends Node3D

## Camera gimbal class. Handles camera rotation and shake.

const MOUSE_SENS: float = 1.0
const MIN_ROT: float = -80.0
const MAX_ROT: float = 80.0

const SPEED_SHAKE_FREQ_MAX: float = 20.0
const SPEED_SHAKE_FREQ_MIN: float = 0.0

@export var phantom_camera: PhantomCamera3D

@onready var tank: PlayerTank = owner


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		camera_rotation_update(event.relative)

	if (event.is_action_pressed("mouse_toggle")):
		if (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	speed_shake_update(delta)


func camera_rotation_update(motion: Vector2) -> void:
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED):
		return

	# Bubba: To prevent having to use overly precise floats as the mouse sensitivity we
	# take the sensitivity and multiply it down to a smaller number.
	# Because converting mouse movement Vector2D to 3D rotation results in a
	# camera that is way too sensitive.
	var sens: float = MOUSE_SENS * 0.001
	rotation.x += motion.y * sens
	rotation.y += -motion.x * sens
	rotation.x = clampf(rotation.x, deg_to_rad(MIN_ROT), deg_to_rad(MAX_ROT))


func speed_shake_update(delta: float) -> void:
	var target_freq: float = \
		clampf(tank.linear_velocity.length() * 0.0025, SPEED_SHAKE_FREQ_MIN, SPEED_SHAKE_FREQ_MAX)
	phantom_camera.noise.frequency = lerpf(phantom_camera.noise.frequency, target_freq, 12.0 * delta)

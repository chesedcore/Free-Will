class_name CameraGimbal extends Node3D

## Camera gimbal class. Handles camera rotation and shake.

const MOUSE_SENS: float = 1.0

@export var phantom_camera: PhantomCamera3D


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		camera_rotation_update(event.relative)


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
	rotation.x = clampf(rotation.x, deg_to_rad(-45), deg_to_rad(45))

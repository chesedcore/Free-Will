class_name CameraGimbal extends Node3D

## Camera gimbal class. Handles camera rotation and shake.

const MOUSE_SENS: float = 1.0
const MIN_ROT: float = -80.0
const MAX_ROT: float = 80.0

@export var phantom_camera: PhantomCamera3D

var screen_shake_value: float = 0.0:
	set(value):
		screen_shake_value = clampf(value, 0.0, 2.0)

@onready var tank: PlayerTank = owner

var screen_shake_time:float = 0
var screen_shake_intensity:float = 10


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		camera_rotation_update(event.relative)

	if (event.is_action_pressed("mouse_toggle")):
		if (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	if (event.is_action_pressed("escape")):
		get_tree().quit()


func _process(delta: float) -> void:
		
	speed_shake_update(delta)
	
	if screen_shake_time > 0:
		phantom_camera.noise.frequency = screen_shake_intensity
		phantom_camera.noise.amplitude = screen_shake_intensity
		screen_shake_time -= delta
	elif screen_shake_time < 0:
		screen_shake_time = 0
	
	if Input.is_action_just_pressed("fire"):
		screen_shake_time = 0.01


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
	screen_shake_value = tank.linear_velocity.length() * 0.0025
	phantom_camera.noise.frequency = \
		lerpf(phantom_camera.noise.frequency, screen_shake_value, 12.0 * delta)
		
	phantom_camera.noise.amplitude = 1
		
		

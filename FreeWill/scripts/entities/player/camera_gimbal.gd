class_name CameraGimbal extends Node3D

## Camera gimbal class. Handles camera rotation and shake.

const MOUSE_SENS: float = 1.0
const MIN_ROT: float = -87.5
const MAX_ROT: float = 87.5

const BASE_FOV := 75.0
const DASH_FOV_TWEEN_TIME := 0.7
const DASH_CAMERA_TWEEN_TIME := 0.7

@export var phantom_camera: PhantomCamera3D

var screen_shake_value: float = 0.0:
	set(value):
		screen_shake_value = clampf(value, 0.0, 2.0)

# dash effect state variables in here
var is_dash_active := false
var dash_timer := 0.0
var base_camera_z := -20.0
var target_fov := BASE_FOV
var target_camera_z := -20.0
var current_fov := BASE_FOV

@onready var tank: PlayerTank = owner
@onready var camera := get_viewport().get_camera_3d()


func _input(event: InputEvent) -> void:
	if (tank.is_dead):
		return

	if (event is InputEventMouseMotion):
		camera_rotation_update(event.relative)

	if (event.is_action_pressed("mouse_toggle")):
		if (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	speed_shake_update(delta)
	dash_effect_update(delta)


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


func trigger_dash_effect(duration: float, fov_boost: float, cam_pullback: float) -> void:
	is_dash_active = true
	target_fov = BASE_FOV + fov_boost
	target_camera_z = base_camera_z - cam_pullback
	start_dash_tween(duration, fov_boost, cam_pullback)

var dash_tween: Tween
var recovery_tween: Tween
func start_dash_tween(duration: float, fov_boost: float, cam_pullback: float) -> void:
	if dash_tween: dash_tween.kill()
	if recovery_tween: recovery_tween.kill()

	dash_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	dash_tween.set_parallel(true)

	dash_tween.tween_property(camera, "fov", BASE_FOV + fov_boost, 0.05)
	var target_pos := phantom_camera.position
	target_pos.z = (base_camera_z - cam_pullback)
	dash_tween.tween_property(phantom_camera, "position:z", target_pos.z, DASH_CAMERA_TWEEN_TIME)

	#return to normal after that duration
	dash_tween.finished.connect(recover.bind(duration))


func recover(duration: float) -> void:
	if recovery_tween: recovery_tween.kill()
	recovery_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	recovery_tween.set_parallel(true)
	recovery_tween.tween_property(camera, "fov", BASE_FOV, duration * 0.5)
	recovery_tween.tween_property(phantom_camera, "position:z", base_camera_z, duration * 0.5)


func dash_effect_update(delta: float) -> void:
	if not is_dash_active: return
	dash_timer -= delta

	if dash_timer <= 0.0:
		is_dash_active = false
		camera.fov = BASE_FOV
		phantom_camera.position.z = base_camera_z

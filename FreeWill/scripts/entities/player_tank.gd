class_name PlayerTank extends RigidBody3D

## sick ass fuckin flying player tank class

const MOUSE_SENS: float = 1.0
const BARREL_ROTATION_SPEED: float = 7.5
const GUN_GIMBAL_ROTATION_SPEED: float = 6.0
const BODY_ROTATION_SPEED: float = 1.0
const GUN_FIRE_FORCE: float = 50.0

@export var barrel: Node3D
@export var gun_gimbal: Node3D
@export var camera_gimbal: Node3D
@export var body_model: Node3D
@export var turret_model: Node3D


func _ready() -> void:
	assert(barrel != null, "barrel node shouldn't be null.")
	assert(gun_gimbal != null, "gun_gimbal node shouldn't be null.")
	# TEMP: Bubba: should the tank handle changing mouse mode? Maybe.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		camera_rotation_update(event.relative)

	if (event.is_action_pressed("fire")):
		fire_cannon()


func _process(delta: float) -> void:
	model_rotation_update(delta)


func camera_rotation_update(motion: Vector2) -> void:
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED):
		return

	# Bubba: To prevent having to use overly precise floats as the mouse sensitivity we
	# take the sensitivity and multiply it down to a smaller number.
	# Because converting mouse movement Vector2D to 3D rotation results in a
	# camera that is way too sensitive.
	var sens: float = MOUSE_SENS * 0.001
	camera_gimbal.rotation.x += motion.y * sens
	camera_gimbal.rotation.y += -motion.x * sens
	camera_gimbal.rotation.x = clampf(camera_gimbal.rotation.x, deg_to_rad(-45), deg_to_rad(45))


func model_rotation_update(delta: float) -> void:
	# gun rotation
	gun_gimbal.rotation.y = \
		lerp_angle(gun_gimbal.rotation.y, camera_gimbal.rotation.y, GUN_GIMBAL_ROTATION_SPEED * delta)
	barrel.rotation.x = \
		lerp_angle(barrel.rotation.x, camera_gimbal.rotation.x, BARREL_ROTATION_SPEED * delta)

	# body model rotates to face gun dir
	body_model.rotation.y = \
		lerp_angle(body_model.rotation.y, camera_gimbal.rotation.y, BODY_ROTATION_SPEED * delta)

	# TODO: Bubba: maybe we could make the tank tilt towards it's velocity slightly. Like a dart.
	# It might look cool.


func fire_cannon() -> void:
	print("BANG")
	linear_velocity += -camera_gimbal.global_transform.basis.z * GUN_FIRE_FORCE

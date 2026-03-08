class_name PlayerTank extends RigidBody3D

## Sick ass fuckin flying player tank class

const BARREL_ROTATION_SPEED: float = 7.5
const GUN_GIMBAL_ROTATION_SPEED: float = 6.0
const BODY_ROTATION_SPEED: float = 1.0
const GUN_FIRE_FORCE: float = 50.0

const CANNON_CAMERA_SHAKE_AMPLITUDE: float = 50.0
const DEFAULT_CAMERA_SHAKE_AMPLITUDE: float = 10.0

@export var barrel: Node3D
@export var camera_gimbal: CameraGimbal

@export var barrel_look_at_marker: Marker3D
@export var barrel_position_marker: Marker3D


func _ready() -> void:
	assert(barrel, "barrel node shouldn't be null.")
	# TEMP: Bubba: should the tank handle changing mouse mode? Maybe.
	# Monarch: We can change it up later when we have a mission handler.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("fire")):
		fire_cannon()


func _process(_delta: float) -> void:
	camera_gimbal.global_position = global_position


func _physics_process(_delta: float) -> void:
	barrel_transform_update()


func barrel_transform_update() -> void:
	barrel.global_position = barrel_position_marker.global_position
	barrel.look_at(barrel_look_at_marker.global_position)


func fire_cannon() -> void:
	linear_velocity += -camera_gimbal.global_transform.basis.z * GUN_FIRE_FORCE
	angular_velocity += -camera_gimbal.global_transform.basis.x * GUN_FIRE_FORCE * 0.1

	# TODO: a better bullet system would be way better. But for now this works.
	var new_bullet: Bullet = preload("res://scenes/projectiles/tank_bullet.scn").instantiate()
	new_bullet.transform = barrel.transform

	# Bubba: to prevent the bullets from looking like they're lagging behind, we add a small amount
	# of the velocity to the bullet's origin
	new_bullet.transform.origin += linear_velocity * 0.01

	new_bullet.linear_velocity = linear_velocity
	
	# Monarch: Usually I'd make a dedicated `Bullets` Node3D that 'holds' this node as an array,
	# then trigger a signal that makes the World handler add the bullet to the Bullets node.
	# But for now (in the spirit of this jam), this will do just fine.
	get_tree().root.add_child.call_deferred(new_bullet)

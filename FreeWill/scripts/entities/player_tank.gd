class_name PlayerTank extends RigidBody3D

## Sick ass fuckin flying player tank class

const BARREL_ROTATION_SPEED: float = 7.5
const GUN_GIMBAL_ROTATION_SPEED: float = 6.0
const BODY_ROTATION_SPEED: float = 1.0
const GUN_FIRE_FORCE: float = 50.0

const MAX_SPEED: float = 100.0

@export var camera_gimbal: CameraGimbal
@export var tank_model: Node3D

@export var barrel_look_at_marker: Marker3D
@export var barrel_position_marker: Marker3D
@export var bullet_spawn_position_marker: Marker3D


func _ready() -> void:
	assert(tank_model, "barrel node shouldn't be null.")
	# TEMP: Bubba: should the tank handle changing mouse mode? Maybe.
	# Monarch: We can change it up later when we have a mission handler.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("fire")):
		fire_cannon()


func _process(_delta: float) -> void:
	camera_gimbal.global_position = global_position


func _physics_process(_delta: float) -> void:
	model_transform_update()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity.x = clampf(state.linear_velocity.x, -MAX_SPEED, MAX_SPEED)
	state.linear_velocity.y = clampf(state.linear_velocity.y, -MAX_SPEED, MAX_SPEED)
	state.linear_velocity.z = clampf(state.linear_velocity.z, -MAX_SPEED, MAX_SPEED)


func model_transform_update() -> void:
	tank_model.global_position = barrel_position_marker.global_position
	tank_model.look_at(barrel_look_at_marker.global_position, Vector3.UP, true)


func fire_cannon() -> void:
	# Particles
	var particles: Node3D = \
		preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()

	#particles.global_transform = bullet_spawn_position_marker.global_transform
	bullet_spawn_position_marker.add_child(particles)

	linear_velocity += -camera_gimbal.global_transform.basis.z * GUN_FIRE_FORCE
	#angular_velocity += -camera_gimbal.global_transform.basis.x * GUN_FIRE_FORCE * 0.1

	# TODO: a better bullet system would be way better. But for now this works.
	var new_bullet: Bullet = preload("res://scenes/projectiles/tank_bullet.scn").instantiate()
	new_bullet.transform = bullet_spawn_position_marker.global_transform

	# Bubba: to prevent the bullets from looking like they're lagging behind, we add a small amount
	# of the velocity to the bullet's origin
	new_bullet.transform.origin += linear_velocity * 0.01

	new_bullet.linear_velocity = linear_velocity

	# Monarch: Usually I'd make a dedicated `Bullets` Node3D that 'holds' this node as an array,
	# then trigger a signal that makes the World handler add the bullet to the Bullets node.
	# But for now (in the spirit of this jam), this will do just fine.
	get_tree().root.add_child.call_deferred(new_bullet)

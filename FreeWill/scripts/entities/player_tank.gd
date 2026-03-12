class_name PlayerTank extends RigidBody3D

## Sick ass fuckin flying player tank class

const BARREL_ROTATION_SPEED: float = 7.5
const GUN_GIMBAL_ROTATION_SPEED: float = 6.0
const BODY_ROTATION_SPEED: float = 1.0
const GUN_FIRE_FORCE: float = 50.0

const MAX_SPEED: float = 150.0

const DASH_FORCE := 200.0
const DASH_COOLDOWN := 4.0
const DASH_FOV_BOOST := 20.0
const DASH_CAMERA_PULLBACK := 10.0
const DASH_EFFECT_DURATION := 10.0

##shorthand for the feedback enum
const UI := UIBus.Feedback

@export var camera_gimbal: CameraGimbal
@export var tank_model: Node3D

@export var barrel_look_at_marker: Marker3D
@export var barrel_position_marker: Marker3D
@export var bullet_spawn_position_marker: Marker3D

var dash_cooldown_timer := 0.0
var is_dashing := false
var dash_effect_timer := 0.0
var is_dead := false


func _ready() -> void:
	GameState.player = self
	assert(tank_model, "barrel node shouldn't be null.")
	# TEMP: Bubba: should the tank handle changing mouse mode? Maybe.
	# Monarch: We can change it up later when we have a mission handler.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("fire")):
		fire_cannon()

	if Input.is_action_just_pressed("dash"):
		attempt_dash()


func attempt_dash() -> void:
	if dash_cooldown_timer > 0.0:
		var error := UI.DASH_STILL_UNDER_COOLDOWN
		UIBus.attempted_dash.emit(Result.Err(error))
		return
	dash()
	UIBus.attempted_dash.emit(Result.Ok_as_is())


func dash() -> void:
	var dash_direction := camera_gimbal.global_basis.z
	linear_velocity += dash_direction * DASH_FORCE

	camera_gimbal.trigger_dash_effect(DASH_EFFECT_DURATION, DASH_FOV_BOOST, DASH_CAMERA_PULLBACK)

	#cooldown
	dash_cooldown_timer = DASH_COOLDOWN
	is_dashing = true
	dash_effect_timer = DASH_EFFECT_DURATION


func dash_timer_update(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if dash_effect_timer > 0.0:
		dash_effect_timer -= delta
		if dash_effect_timer <= 0.0:
			is_dashing = false


func _process(delta: float) -> void:
	dash_timer_update(delta)


func _physics_process(_delta: float) -> void:
	model_transform_update()
	camera_gimbal.global_position = global_position


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity.x = clampf(state.linear_velocity.x, -MAX_SPEED, MAX_SPEED)
	state.linear_velocity.y = clampf(state.linear_velocity.y, -INF, MAX_SPEED)
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


func kill() -> void:
	if (is_dead):
		return

	is_dead = true
	freeze = is_dead

	tank_model.hide()

	var game_over_scene: GameOverScene = \
		(load("res://scenes/entities/game_over_scene.tscn") as PackedScene).instantiate()

	game_over_scene.player = self
	get_tree().root.add_child.call_deferred(game_over_scene)

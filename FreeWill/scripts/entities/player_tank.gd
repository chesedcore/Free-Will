class_name PlayerTank extends RigidBody3D

## Sick ass fuckin flying player tank class

const BARREL_ROTATION_SPEED: float = 7.5
const GUN_GIMBAL_ROTATION_SPEED: float = 6.0
const BODY_ROTATION_SPEED: float = 1.0
const GUN_FIRE_FORCE: float = 50.0

const MAX_SPEED: float = 150.0

const DASH_FORCE := 350.0
const DASH_COOLDOWN := 10.0
const DASH_MAX_SPEED := MAX_SPEED * 3
const DASH_FOV_BOOST := 20.0
const DASH_CAMERA_PULLBACK := 6.0
const DASH_EFFECT_DURATION := 5.0

const GRAPPLE_STRENGTH: float = 25.0

const ACTION_COOLDOWN := 3.25

const MAX_HEALTH: float = 100.0

##shorthand for the feedback enum
const UI := UIBus.Feedback

@export var camera_gimbal: CameraGimbal
@export var tank_model: Node3D

@export var barrel_look_at_marker: Marker3D
@export var barrel_position_marker: Marker3D
@export var bullet_spawn_position_marker: Marker3D


@export var turret: MeshInstance3D
@export var hull: MeshInstance3D


@export var cannon_fire_sound: AudioStream = preload("res://audio/sfx/rocket_launch.ogg")

var dash_cooldown_timer := 0.0
var is_dashing := false
var dash_effect_timer := 0.0

var is_dead := false
var health := MAX_HEALTH

var action_cooldown_timer := 0.0
var is_in_action := false
var action_window_timer := 0.0

var is_spinning_turret := false
var is_parrying := false
var is_grappling := true

var grappled_target: PhysicsBody3D = null


func _ready() -> void:
	GameState.player = self
	assert(tank_model, "barrel node shouldn't be null.")
	# TEMP: Bubba: should the tank handle changing mouse mode? Maybe.
	# Monarch: We can change it up later when we have a mission handler.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _wire_up_signals() -> void:
	UIBus.missile_parried.connect(_extend_parry_window)


func _extend_parry_window() -> void:
	pass

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("fire")):
		fire_cannon()

	if (event.is_action_pressed("grapple")):
		grapple()

	if (event.is_action_released("grapple")):
		ungrapple()

	if Input.is_action_just_pressed("dash"):
		attempt_dash()

	if Input.is_action_just_pressed("action"):
		attempt_action()


func _process(delta: float) -> void:
	dash_timer_update(delta)
	action_timer_update(delta)


func _physics_process(delta: float) -> void:
	if not is_in_action: model_transform_update(delta)
	camera_gimbal.global_position = global_position
	if is_spinning_turret: spin_turret(70 * delta)



func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	grapple_update()
	var max_speed := DASH_MAX_SPEED if is_dashing else MAX_SPEED
	state.linear_velocity.x = clampf(state.linear_velocity.x, -max_speed, max_speed)
	state.linear_velocity.y = clampf(state.linear_velocity.y, -INF, max_speed)
	state.linear_velocity.z = clampf(state.linear_velocity.z, -max_speed, max_speed)


func spin_turret(by_angle: float) -> void:
	turret.rotate_y(by_angle)


func attempt_action() -> void:
	if action_cooldown_timer > 0.0:
		var error := UI.ACTION_STILL_UNDER_COOLDOWN
		UIBus.attempted_action.emit(Result.Err(error))
		return
	action()
	UIBus.attempted_action.emit(Result.Ok_as_is())


func action() -> void:
	static_parry()


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


func grapple() -> void:
	grappled_target = IFFTracker.get_lock_this_frame().unwrap_unchecked()
	if (!grappled_target):
		return

	print("GRAPPLED")


func ungrapple() -> void:
	if (grappled_target):
		grappled_target = null
		return


func grapple_update() -> void:
	if (grappled_target):
		linear_velocity += \
			global_position.direction_to(grappled_target.global_position) * GRAPPLE_STRENGTH
		if (global_position.distance_squared_to(grappled_target.global_position) < 500.0):
			grappled_target = null


func dash_timer_update(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if dash_effect_timer > 0.0:
		dash_effect_timer -= delta
		if dash_effect_timer <= 0.0:
			is_dashing = false


func action_timer_update(delta: float) -> void:
	if action_cooldown_timer > 0.0:
		action_cooldown_timer -= delta

	if action_window_timer > 0.0:
		action_window_timer -= delta
		if action_window_timer <= 0.0:
			is_in_action = false


##this is ugly because allocating a new temp var every frame for a quat might be
##ugly ass for performance, so no extra allocs are made on purpose
func model_transform_update(delta: float) -> void:
	tank_model.global_position = barrel_position_marker.global_position
	tank_model.global_transform.basis = \
	tank_model.global_transform.basis.slerp(
		tank_model.global_transform.looking_at(
			barrel_look_at_marker.global_position,
			Vector3.UP,
			true
		).basis,
		6.0 * delta
	)


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

	# Bubba: Lockon shit
	# Iff target CAN be null. The missiles will just not track anything
	var iff_tracked_target: PhysicsBody3D = IFFTracker.get_lock_this_frame().unwrap_unchecked()
	new_bullet.target = iff_tracked_target

	# Monarch: Usually I'd make a dedicated `Bullets` Node3D that 'holds' this node as an array,
	# then trigger a signal that makes the World handler add the bullet to the Bullets node.
	# But for now (in the spirit of this jam), this will do just fine.
	get_tree().root.add_child.call_deferred(new_bullet)

var t_action: Tween

func static_parry() -> void:
	if t_action: t_action.kill()
	t_action = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t_action.set_parallel(true)
	t_action.tween_callback(func() -> void:
		is_in_action = true
		action_cooldown_timer = ACTION_COOLDOWN
	)
	t_action.tween_property(tank_model, "rotation_degrees:x", -30, 0.2)
	t_action.chain()
	t_action.tween_callback(func() -> void:
		is_spinning_turret = true
		is_parrying = true
		freeze = true
	)
	t_action.tween_property(tank_model, "rotation_degrees:x", 120, 0.325)
	#t_action.tween_property(tank_model, "rotation_degrees:z", 360, 0.5)
	#t_action.tween_property(tank_model, "rotation_degrees:z", 70, 0.3)
	t_action.finished.connect(_on_action_recovery)


func _on_action_recovery() -> void:
	is_in_action = false
	is_spinning_turret = false
	is_parrying = false
	freeze = false

	AudioManager.play_sound_at(barrel_position_marker.global_position, cannon_fire_sound)


func damage(amount: float) -> void:
	health -= amount
	if (health <= 0.0):
		kill()


func kill() -> void:
	if (is_dead):
		return

	is_dead = true
	freeze = is_dead

	tank_model.hide()

	var game_over_scene: GameOverScene = \
		(load("res://scenes/entities/game_over_scene.tscn") as PackedScene).instantiate()

	game_over_scene.player = self

	AudioManager.play_sound_at(global_position, preload("res://audio/sfx/large_explosion.ogg"), 15.0)
	get_tree().root.add_child.call_deferred(game_over_scene)

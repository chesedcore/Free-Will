class_name PlayerTank extends RigidBody3D

## Sick ass fuckin flying player tank class

signal fucking_exploded

const BARREL_ROTATION_SPEED: float = 7.5
const GUN_GIMBAL_ROTATION_SPEED: float = 6.0
const BODY_ROTATION_SPEED: float = 1.0
const GUN_FIRE_FORCE: float = 50.0
const GRAPPLE_STRENGTH: float = 25.0

const MAX_SPEED: float = 150.0

const DASH_FORCE := 350.0
const DASH_COOLDOWN := 6.325
const DASH_MAX_SPEED := MAX_SPEED * 3
const DASH_FOV_BOOST := 20.0
const DASH_CAMERA_PULLBACK := 6.0
const DASH_EFFECT_DURATION := 5.0

# TODO: Bubba: this may be too few missles. I do think preventing the player from spamming
# the missiles is a good idea. Probably needs adjusting tho
const MAX_MISSILES: int = 3

const ACTION_COOLDOWN := 3.25
const PARRY_COOLDOWN := 1.25
const PARRY_WINDUP := 0.2
const PARRY_WINDOW := 0.625
const PARRY_CHAIN_EXTENSION := 0.4

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
@export var cannon_fire_sound: AudioStream
@export var shake_component: Shaker
@export var grapple_rope_mesh_1: MeshInstance3D
@export var grapple_rope_mesh_2: MeshInstance3D
@export var kunai_model: Node3D

#cooldowns
@onready var dash_cooldown := Cooldown.from_time(DASH_COOLDOWN, self)
@onready var parry_cooldown := Cooldown.from_time(PARRY_COOLDOWN, self)
@onready var parry_window_timer := Cooldown.from_time(PARRY_WINDOW, self)
@onready var dash_effect_timer := Cooldown.from_time(DASH_EFFECT_DURATION, self)

#flag hell
var health := MAX_HEALTH
var is_dead := false
var _stop_gimbal_update := false
var _parry_tween: Tween
var grappled_target: Node3D
var active_missiles: int = 0
var grapple_hold_time: float = 0.0



func _ready() -> void:
	_wire_up_signals()
	assert(tank_model, "Tank model shouldn't be null.")
	GameState.player = self
	shake_component.set_target(tank_model)

func _wire_up_signals() -> void:
	UIBus.missile_parried.connect(_extend_parry_window)
	parry_window_timer.timeout.connect(_end_parry)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_fire_cannon()

	if Input.is_action_just_pressed("dash"):
		_attempt_dash()

	if Input.is_action_just_pressed("action"):
		_attempt_parry()

	if (event.is_action_pressed("grapple")):
		grapple()

	if (event.is_action_released("grapple")):
		ungrapple()


func _attempt_dash() -> void:
	if not dash_cooldown.is_ready():
		UIBus.attempted_dash.emit(Result.Err(UI.DASH_STILL_UNDER_COOLDOWN))
		return

	_execute_dash()
	UIBus.attempted_dash.emit(Result.Ok_as_is())


func _execute_dash() -> void:
	var dash_direction := camera_gimbal.global_basis.z
	linear_velocity += dash_direction * DASH_FORCE

	camera_gimbal.trigger_dash_effect(DASH_EFFECT_DURATION, DASH_FOV_BOOST, DASH_CAMERA_PULLBACK)

	dash_cooldown.start_cooldown()
	dash_effect_timer.start_cooldown()


func _attempt_parry() -> void:
	if not parry_cooldown.is_ready():
		UIBus.attempted_action.emit(Result.Err(UI.ACTION_STILL_UNDER_COOLDOWN))
		return

	_execute_parry()
	UIBus.attempted_action.emit(Result.Ok_as_is())


func _execute_parry() -> void:
	if _parry_tween:
		_parry_tween.kill()

	_parry_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	_parry_tween.set_parallel(true)

	#windup happens here
	_parry_tween.tween_callback(func() -> void:
		_stop_gimbal_update = true
	)
	_parry_tween.tween_property(tank_model, "rotation_degrees:x", -30, PARRY_WINDUP)

	#windup ends, active parry window here
	_parry_tween.chain()
	_parry_tween.tween_callback(func() -> void:
		parry_window_timer.start_cooldown()
	)
	_parry_tween.tween_property(tank_model, "rotation_degrees:x", 120, PARRY_WINDOW)
	_parry_tween.finished.connect(_on_parry_finished)

	parry_cooldown.start_cooldown()


func _on_parry_finished() -> void:
	#animation is done, but that damned window might still be active
	if parry_window_timer.is_ready():
		_end_parry()


func _end_parry() -> void:
	_stop_gimbal_update = false
	AudioManager.play_sound_at(barrel_position_marker.global_position, cannon_fire_sound)


func _extend_parry_window() -> void:
	if parry_window_timer.is_active():
		parry_window_timer.start(PARRY_CHAIN_EXTENSION)
		print_rich("[color=blue]Parry window extended!")


func _fire_cannon() -> void:
	if (active_missiles >= MAX_MISSILES):
		return

	CannonParticles.attach_to(bullet_spawn_position_marker)
	linear_velocity += -camera_gimbal.global_transform.basis.z * GUN_FIRE_FORCE
	Bullet.fire_bullet_from_tank(self)
	active_missiles += 1


func bullet_deleted() -> void:
	print("DELTED")
	active_missiles -= 1


func try_damage(amount: float) -> Result:
	if parry_window_timer.is_active():
		return Result.Err(ParryReport.as_normal())

	damage(amount)
	return Result.Ok_as_is()


func damage(amount: float) -> void:
	health -= amount
	if health <= 0.0: _kill()


func _kill() -> void:
	if is_dead: return
	is_dead = true
	freeze = true
	fucking_exploded.emit()


func _physics_process(delta: float) -> void:
	grapple_update(delta)
	_poll_tank_death()

	if not _stop_gimbal_update and not parry_window_timer.is_active():
		_update_model_transform(delta)

	camera_gimbal.global_position = global_position

	#spin turret during parry!!
	if parry_window_timer.is_active():
		turret.rotate_y(70 * delta)

func _poll_tank_death() -> void:
	if global_position.y < -5.0: _kill()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var max_speed := DASH_MAX_SPEED if dash_effect_timer.is_active() else MAX_SPEED
	state.linear_velocity.x = clampf(state.linear_velocity.x, -max_speed, max_speed)
	state.linear_velocity.y = clampf(state.linear_velocity.y, -INF, max_speed)
	state.linear_velocity.z = clampf(state.linear_velocity.z, -max_speed, max_speed)


func _update_model_transform(delta: float) -> void:
	tank_model.global_position = barrel_position_marker.global_position
	tank_model.global_transform.basis = tank_model.global_transform.basis.slerp(
		tank_model.global_transform.looking_at(
			barrel_look_at_marker.global_position,
			Vector3.UP,
			true
		).basis,
		6.0 * delta
	)
	turret.rotation.y = lerpf(turret.rotation.y, 0.0, 6.0 * delta)

func grapple() -> void:
	grappled_target = IFFTracker.get_lock_this_frame().unwrap_unchecked()
	if (!grappled_target):
		return
	print("GRAPPLED")

func ungrapple() -> void:
	if (grappled_target):
		grapple_hold_time = 0.0
		grappled_target = null
		return

func grapple_update(delta: float) -> void:
	var grapple_speed: float = 5.0

	grapple_rope_mesh_1.visible = (grappled_target != null)
	grapple_rope_mesh_2.visible = (grappled_target != null)
	kunai_model.visible = (grappled_target != null)

	if (!grappled_target):
		kunai_model.global_position = global_position
		return

	if (grapple_hold_time < 0.5):
		kunai_model.global_position = \
			kunai_model.global_position.lerp(grappled_target.global_position, grapple_speed * delta)

		if (kunai_model.global_position.distance_squared_to(grappled_target.global_position) > 100.0):
			kunai_model.rotation.x += 25.0 * delta
	else:
		kunai_model.global_position = grappled_target.global_position

	grapple_hold_time += delta

	(grapple_rope_mesh_1.material_override as ShaderMaterial).set_shader_parameter(
		"end_position",
		kunai_model.global_position)

	(grapple_rope_mesh_2.material_override as ShaderMaterial).set_shader_parameter(
		"end_position",
		kunai_model.global_position)

	linear_velocity += \
		global_position.direction_to(grappled_target.global_position) * GRAPPLE_STRENGTH

	if (global_position.distance_squared_to(grappled_target.global_position) < 500.0):
		grappled_target = null

func stop_model_update() -> void:
	_stop_gimbal_update = true

func start_model_update() -> void:
	_stop_gimbal_update = false

func shake(for_time: float = 1.5) -> void:
	shake_component.shake(for_time)

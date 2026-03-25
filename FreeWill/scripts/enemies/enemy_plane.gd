class_name EnemyPlane extends BaseEnemy

const HOMINGMISSLE = preload("res://scenes/projectiles/enemy_projectie/homingmissle.tscn")
const SHIELD = preload("res://scenes/entities/combat/shield.tscn")

@export var obstacle_detectors : Array[RayCast3D]
@export var trail_renderer: TrailRenderer
@export var speed : float  = 200.0
@export var turn_speed : float= 1.25

enum STATES {INTERCEPT,EVADE,ATTACK}

@export var lock_on_timer: Timer
@export var missle_spawner: Node3D
@export var line_of_sight: Area3D
@export var initial_state : STATES

var current_state : State
var shield : Node3D
var is_shield_active : bool = false
@export var shield_scale: float = 15


func wire_signals()->void:
	EnemySignalBus.cargo_ship_shield.connect(on_shield)
	EnemySignalBus.cargo_ship_deactivate_shield.connect(on_deactivate_shield)



func on_shield()->void :
	if !is_shield_active:
		is_shield_active = true
		shield = SHIELD.instantiate()
		shield.scale = shield.scale * shield_scale
		add_child(shield)
		print("added")

func on_deactivate_shield()->void:
	if is_shield_active:

		shield.queue_free.call_deferred()
		shield = null
		print("removed")
		is_shield_active = false


func _ready() -> void:
	wire_signals()
	var new_state : State = create_state(initial_state)
	new_state.enter()
	current_state = new_state



func create_state(state :STATES)->State:
	var new_state : State

	match  state:
		STATES.INTERCEPT:
			new_state = InterceptState.intercept_state_from(self,model,line_of_sight,obstacle_detectors)
			new_state.speed = speed
			new_state.turn_speed = turn_speed
			new_state.Transitioned.connect(on_state_transition)

		STATES.ATTACK:
			new_state = AttackState.attack_state_from(self,lock_on_timer,line_of_sight)
			new_state.fireMissle.connect(on_fire_missile)
			new_state.speed = speed
			new_state.Transitioned.connect(on_state_transition)

		STATES.EVADE:
			new_state = EvadeState.evade_state_from(self,model,obstacle_detectors)
			new_state.speed = speed
			new_state.turn_speed = turn_speed
			new_state.Transitioned.connect(on_state_transition)

	return new_state


func on_fire_missile(target : Node3D)->void:
	var new_missile :HomingMissile = HOMINGMISSLE.instantiate()

	new_missile.target_node = target
	get_tree().root.add_child(new_missile)
	new_missile.global_position = missle_spawner.global_position


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
	move_and_slide()


func on_state_transition(from_state: State, to_state: STATES)->void:
	if from_state != current_state:
		return

	if to_state == null:
		return

	var new_state : State = create_state(to_state)
	if current_state:
		current_state.exit()

	new_state.enter()
	current_state = new_state

func kill() -> void:
	if !is_shield_active:
		super.kill()

#func kill() -> void:
	#var trail := trail_renderer
	#if is_instance_valid(trail):
		#trail.is_emitting = false
		#remove_child(trail)
		#get_tree().root.add_child(trail)
	#super()

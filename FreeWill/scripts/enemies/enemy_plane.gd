class_name EnemyPlane extends BaseEnemy

@export var lock_on_timer: Timer
@export var mesh_instance_3d: MeshInstance3D

@export var missle_spawner: Node3D
const HOMINGMISSLE = preload("res://scenes/projectiles/enemy_projectie/homingmissle.tscn")

@export var line_of_sight: Area3D


var current_state : State

enum STATES {INTERCEPT,EVADE,ATTACK}

@export var initial_state : STATES



func _ready() -> void:
	
	var new_state : State = create_state(initial_state)
	
	new_state.enter()
	current_state = new_state
	
	
func create_state(state :STATES)->State:
	var new_state : State
	
	match  state:
		STATES.INTERCEPT:
			
			new_state = InterceptState.intercept_state_from(self,line_of_sight)
			new_state.marker = mesh_instance_3d
			new_state.Transitioned.connect(on_state_transition)
		STATES.ATTACK:
			new_state = AttackState.attack_state_from(self,lock_on_timer,line_of_sight)
			new_state.fireMissle.connect(on_fire_missile)
			new_state.Transitioned.connect(on_state_transition)
		STATES.EVADE:
			new_state = EvadeState.evade_state_from(self)
			new_state.marker = mesh_instance_3d
			new_state.Transitioned.connect(on_state_transition)
			
	return new_state
	

func on_fire_missile(target : Node3D)->void:
	var new_missile :HomingMissle = HOMINGMISSLE.instantiate()
	
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




	

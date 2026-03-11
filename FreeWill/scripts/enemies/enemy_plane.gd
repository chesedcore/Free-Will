class_name EnemyPlane extends BaseEnemy

@export var lock_on_timer: Timer
@export var mesh_instance_3d: MeshInstance3D

@export var missle_spawner: Node3D
const HOMINGMISSLE = preload("res://scenes/projectiles/enemy_projectie/homingmissle.tscn")



var current_state : State

enum STATE_TYPES {INTERCEPT,EVADE,ATTACK}
var states :Dictionary={
	"interceptstate": STATE_TYPES.INTERCEPT,
	"evadingstate" : STATE_TYPES.EVADE,
	"attackstate" : STATE_TYPES.ATTACK
}
@export var initial_state : STATE_TYPES



func _ready() -> void:
	
	var new_state : State = create_state(initial_state)
	
	new_state.enter()
	current_state = new_state
	
	
func create_state(state :STATE_TYPES)->State:
	var new_state : State
	
	match  state:
		STATE_TYPES.INTERCEPT:
			
			new_state = InterceptState.new(self)
			new_state.marker = mesh_instance_3d
			new_state.Transitioned.connect(on_state_transition)
		STATE_TYPES.ATTACK:
			new_state = AttackState.new(self,lock_on_timer)
			new_state.fireMissle.connect(on_fire_missile)
			
			new_state.Transitioned.connect(on_state_transition)
		STATE_TYPES.EVADE:
			new_state = EvadeState.new(self)
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


func on_state_transition(state: State, new_state_name: String)->void:
	if state != current_state:
		return

	var new_state_type : STATE_TYPES = states.get(new_state_name.to_lower())

	if new_state_type == null:
		return
	var new_state : State = create_state(new_state_type)
	if current_state:
		current_state.exit()

	new_state.enter()
	current_state = new_state




	

class_name StateMachine extends Node

var current_state : State

enum STATE_TYPES {INTERCEPT,DODGE}
var states :Dictionary={
	"interceptstate": STATE_TYPES.INTERCEPT,
	"dodgingstate" : STATE_TYPES.DODGE
}
@export var initial_state : String



func _ready() -> void:
	var new_state_type : STATE_TYPES = states.get(initial_state.to_lower())

	if new_state_type== null:
		
		return
	var new_state : State = create_state(new_state_type)
	

	new_state.enter()
	current_state = new_state
	
	
func create_state(state :STATE_TYPES)->State:
	var new_state : State
	
	match  state:
		STATE_TYPES.INTERCEPT:
			
			new_state = InterceptState.new(get_parent())
			new_state.marker = get_parent().mesh_instance_3d
			new_state.Transitioned.connect(on_state_transition)
	return new_state
	


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


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

class_name EnemyBattleship extends BaseEnemy



@export var obstacle_detectors : Array[RayCast3D]
@export var line_of_sight: Area3D
@export var cannon_bases : Array[Node3D]
@export var cannon_barrels : Array[Node3D]
var current_state : State
@export var battle_ship_model: Node3D

enum STATES {IDLE,ATTACK}

@export var initial_state : STATES



func _ready() -> void:
	
	var new_state : State = create_state(initial_state)
	
	new_state.enter()
	current_state = new_state
	floating_animation()
	
func create_state(state :STATES)->State:
	var new_state : State
	#
	match  state:
		STATES.ATTACK:
			#
			new_state = ShipAttackState.ship_attackstate_from(self,cannon_bases,cannon_barrels)
			
			new_state.Transitioned.connect(on_state_transition)
		STATES.IDLE:
			new_state = ShipWanderState.wander_state_from(self,obstacle_detectors)
			new_state.Transitioned.connect(on_state_transition)
	return new_state
	


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
	
var bob_up_pos:float = 5
var bob_up_deg: float = 5
var bob_down_pos:float = -5
var bob_down_deg: float = -10


func floating_animation()->void:
	var pos_tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	pos_tween.tween_property(battle_ship_model,"global_position:y",bob_up_pos,2)
	pos_tween.tween_property(battle_ship_model,"global_position:y",bob_down_pos,2)
	var deg_tween :Tween=  create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	deg_tween.tween_property(battle_ship_model,"global_rotation_degrees:z",bob_up_deg,2)
	deg_tween.tween_property(battle_ship_model,"global_rotation_degrees:z",bob_down_deg,2)
	var floating_tween : Tween = create_tween().set_loops().set_parallel(true)
	floating_tween.tween_subtween(pos_tween)
	floating_tween.tween_subtween(deg_tween)
	
	


	

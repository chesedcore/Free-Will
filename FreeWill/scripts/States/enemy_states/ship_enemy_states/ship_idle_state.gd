class_name ShipidleState extends EnemyState


var los : Area3D

func enter() -> void:
	los.body_entered.connect(on_los_body_entered)

@warning_ignore("shadowed_variable")
static  func  ship_idlekstate_from(owner : BaseEnemy,los: Area3D)->State:
	var state: ShipidleState = new()
	state.enemy = owner
	state.player = GameState.player
	state.los = los
	return state

func exit() -> void:
	los.body_entered.disconnect(on_los_body_entered)

func on_los_body_entered(body : Node3D)->void:
	if body is PlayerTank:
		Transitioned.emit(self,EnemyBattleship.STATES.ATTACK)

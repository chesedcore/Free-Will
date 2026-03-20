class_name EnemyCargoShip extends BaseEnemy

@export var cargo_ship_model: Node3D



func _ready() -> void:
	floating_animation()


var bob_up_pos:float = 5
var bob_up_deg: float = 5
var bob_down_pos:float = -5
var bob_down_deg: float = -10


func floating_animation()->void:
	var pos_tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	pos_tween.tween_property(cargo_ship_model,"global_position:y",bob_up_pos,2)
	pos_tween.tween_property(cargo_ship_model,"global_position:y",bob_down_pos,2)
	var deg_tween :Tween=  create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	deg_tween.tween_property(cargo_ship_model,"global_rotation_degrees:z",bob_up_deg,2)
	deg_tween.tween_property(cargo_ship_model,"global_rotation_degrees:z",bob_down_deg,2)
	var floating_tween : Tween = create_tween().set_loops().set_parallel(true)
	floating_tween.tween_subtween(pos_tween)
	floating_tween.tween_subtween(deg_tween)
	
	
func kill() -> void:
	EnemySignalBus.cargo_ship_deactivate_shield.emit()
	super.kill()


func _on_shield_refresh_time_timeout() -> void:
	EnemySignalBus.cargo_ship_shield.emit()

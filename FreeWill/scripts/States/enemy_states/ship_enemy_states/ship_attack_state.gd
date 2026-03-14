class_name ShipAttackState extends EnemyState

var cannon_bases : Array[Node3D]
var cannon_barrels : Array[Node3D]
var rotation_speed: float = 5.0

static  func  ship_attackstate_from(owner : BaseEnemy,bases: Array[Node3D],barrels : Array[Node3D])->State:
	var state: ShipAttackState = new()
	state.enemy = owner
	state.player = GameState.player
	state.cannon_bases = bases
	state.cannon_barrels = barrels
	return state


func physics_update(_delta :float) -> void:
	if player:
		for base in cannon_bases:
			var target_dir : Vector3 = (player.global_position - base.global_position).normalized()
			var target_angle :float = atan2(target_dir.x, target_dir.z)
			base.rotation.y = lerp_angle(base.rotation.y, target_angle , rotation_speed * _delta)
		for barrel in cannon_barrels:
			var target_dir : Vector3 = (player.global_position - barrel.global_position)
			var horizontal_dist: float = Vector2(target_dir.x, target_dir.z).length()
			var target_angle :float = atan2(target_dir.y, horizontal_dist)
			barrel.rotation.z = lerp_angle(barrel.rotation.z, target_angle   , rotation_speed * _delta)

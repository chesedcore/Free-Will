class_name EnemyState extends State

var player : PhysicsBody3D
var enemy : BaseEnemy

static  func init_state(owner : BaseEnemy)-> EnemyState:
	var enemystate :EnemyState = new()
	enemystate.player = GameState.player
	enemystate.enemy = owner
	return enemystate

#func _init(owner :BaseEnemy) -> void:
	#player = GameState.player
	#assert(player, "Player shouldn't be null")
	#enemy = owner
#


#func _ready() -> void:
	#player = GameState.player
	#assert(player, "Player shouldn't be null")
	#enemy = owner

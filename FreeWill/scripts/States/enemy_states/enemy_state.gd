class_name EnemyState extends State

var player : PhysicsBody3D
var enemy : BaseEnemy

func _init(owner :BaseEnemy) -> void:
	player = GameState.player
	assert(player, "Player shouldn't be null")
	enemy = owner



#func _ready() -> void:
	#player = GameState.player
	#assert(player, "Player shouldn't be null")
	#enemy = owner

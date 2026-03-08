class_name EnemyState extends State

var player : PhysicsBody3D
var enemy : BaseEnemy


func _ready() -> void:
	player = GameState.player
	assert(player, "Player shouldn't be null")
	enemy = owner

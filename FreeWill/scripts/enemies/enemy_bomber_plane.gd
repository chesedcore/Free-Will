class_name  EnemyBomberPlane extends BaseEnemy

@export var droppers : Array[Node3D]
const BOMB = preload("res://scenes/entities/combat/bomb.tscn")

const  BORDER = 5000

var speed : float= 150
var dir : Vector3
var heading : Vector3 = Vector3.ZERO
func _ready() -> void:
	dir = global_position.direction_to(GameState.player.global_position)
	dir.y = 0
	dir = dir.normalized()
	look_at(global_position + dir, Vector3.UP)
	heading = -global_basis.z
	

func _physics_process(delta: float) -> void:
	velocity = heading * speed 
	move_and_slide()
	if (global_position.x >= BORDER or global_position.x <= -BORDER) or  (global_position.z >= BORDER or global_position.z <= -BORDER):
		kill()
 
func _on_drop_timer_timeout() -> void:
	var new_bomb : Bomb= BOMB.instantiate()
	new_bomb.position = droppers.pick_random().global_position
	new_bomb.name = "Bomb"
	#GAEL : I KNOW THIS IS FUCKED ILL REPLACE IT WITH SOME SIGNAL TO STAGE HANDLER LATEEERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
	#get_parent().get_parent().add_child.call_deferred(new_bomb
	
	EnemySignalBus.spawn_entity.emit(new_bomb)

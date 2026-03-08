class_name PlaneWander extends EnemyState

@export var move_speed : float = 10.0
@export var turn_speed : float = 3.5
var heading : Vector3 = Vector3.FORWARD
var move_direction : Vector3
var wander_time : float

func randomize_wander()->void:
	move_direction = Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)).normalized()
	wander_time = randf_range(5,7)


func enter()->void:
	randomize_wander()

func update(_delta : float)->void:
	if wander_time>0:
		wander_time -= _delta
	else:
		randomize_wander()
	
func physics_update(_delta :float)->void:
	if enemy:
		heading = heading.slerp(move_direction,turn_speed* _delta)
		enemy.look_at(enemy.global_position + heading, Vector3.UP)

		enemy.velocity = heading * move_speed

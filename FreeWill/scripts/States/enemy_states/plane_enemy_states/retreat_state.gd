class_name RetreatState extends EnemyState

@export var move_speed : float = 10.0
@export var turn_speed : float = 2.5
@export var retreat_time: float

var heading : Vector3 = Vector3.FORWARD
var retreat_direction : Vector3
var player_direction : Vector3


func enter()->void:
	player_direction =  player.global_position - enemy.global_position
	retreat_time = randf_range(1,4)


func update(_delta : float)->void:
	pass


func physics_update(_delta :float)->void:
	if enemy and player:
		if retreat_time >0 :
			retreat_time -= _delta
		else:
			Transitioned.emit(self,"aimingstate")

		retreat_direction = Vector3( player_direction + Vector3(randi_range(-100,100),randi_range(-100,100),0) ).normalized()
		heading = heading.slerp(retreat_direction,turn_speed * _delta)
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = heading * move_speed

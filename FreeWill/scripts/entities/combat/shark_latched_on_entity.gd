class_name SharkLatchedOn extends Node3D


@export var duration : float = 5

var latched_on_tank : PlayerTank

const PULLFORCE = 10

func _physics_process(delta: float) -> void:
	if latched_on_tank:
		latched_on_tank.linear_velocity.y -=PULLFORCE

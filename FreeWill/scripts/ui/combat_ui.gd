class_name CombatUI extends Node

@export var iff_layer: Control
@onready var iff_tracker := IFFTracker.from_control(iff_layer)
var tank: PlayerTank


func track_these_entities(entities: Array[Node]) -> void:
	assert(tank, "No tank slotted in!")
	for entity in entities:
		assert(entity is PhysicsBody3D, "That entity isn't trackable!")
		iff_tracker.track_entity(entity, entity.name)


func _process(_delta: float) -> void:
	iff_tracker.tick(tank)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cycle_targets"):
		iff_tracker.cycle_lock(tank)

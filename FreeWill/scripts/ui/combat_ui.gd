class_name CombatUI extends Node

@export var nametags_layer: Control
@onready var nametags := IFFTracker.from_control(nametags_layer)

func track_these_entities(entities: Array[Node]) -> void:
	for entity in entities:
		assert(entity is PhysicsBody3D, "That entity isn't trackable!")
		nametags.track_entity(entity, entity.name)

func _process(_delta: float) -> void:
	nametags.tick()

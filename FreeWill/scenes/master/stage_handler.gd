class_name StageHandler extends Node3D

@export var ui: CombatUI
@export var enemies_list: EnemiesList

func setup_name_tracking() -> void:
	var enemies := enemies_list.get_enemies()
	ui.track_these_entities(enemies)

func _ready() -> void:
	setup_name_tracking()

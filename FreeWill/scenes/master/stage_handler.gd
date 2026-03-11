class_name StageHandler extends Node3D

@export var ui: CombatUI
@export var enemies_list: EnemiesList
@export var tank: PlayerTank

func setup_name_tracking() -> void:
	ui.tank = tank
	var enemies := enemies_list.get_enemies()
	ui.track_these_entities(enemies)
	

func _ready() -> void:
	setup_name_tracking()

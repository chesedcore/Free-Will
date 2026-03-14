class_name StageHandler extends Node3D

@export var ui: CombatUI
@export var enemies_list: EnemiesList
@export var tank: PlayerTank

const HITSTOP_TIME := 1

var _is_under_hitstop := false

func _wire_up_signals() -> void:
	UIBus.missile_parried.connect(_on_missile_parried)

func setup_name_tracking() -> void:
	ui.tank = tank
	var enemies := enemies_list.get_enemies()
	ui.track_these_entities(enemies)

func _ready() -> void:
	_wire_up_signals()
	setup_name_tracking()

func _on_hitstop_timer_expired() -> void:
	Engine.time_scale = 1
	_is_under_hitstop = false 

func _on_missile_parried() -> void:
	if _is_under_hitstop: return
	
	_is_under_hitstop = true
	Engine.time_scale = 0.08
	
	var hitstop_timer := get_tree().create_timer(HITSTOP_TIME, true, false, true)
	hitstop_timer.timeout.connect(_on_hitstop_timer_expired, CONNECT_ONE_SHOT)

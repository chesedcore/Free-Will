class_name StageHandler extends Node3D

@export var ui: CombatUI
@export var enemies_list: EnemiesList
@export var tank: PlayerTank

const HITSTOP_TIME := 1
const HITSTOP_SLOW_DOWN_FACTOR := 0.08

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_wire_up_signals()
	_setup_name_tracking()
	Dialogic.Inputs.block_input(10000)
	Dialogic.start("test")

var _is_under_hitstop := false

func _wire_up_signals() -> void:
	UIBus.missile_parried.connect(_on_missile_parried)
	tank.fucking_exploded.connect(_on_tank_fucking_exploded)

func _setup_name_tracking() -> void:
	ui.set_tank(tank)
	var enemies := enemies_list.get_enemies()
	ui.track_these_entities(enemies)

func _on_hitstop_timer_expired() -> void:
	Engine.time_scale = 1
	_is_under_hitstop = false 

func _hitstop() -> void:
	if _is_under_hitstop: return
	_is_under_hitstop = true
	Engine.time_scale = HITSTOP_SLOW_DOWN_FACTOR
	
	var hitstop_timer := get_tree().create_timer(HITSTOP_TIME, true, false, true)
	hitstop_timer.timeout.connect(_on_hitstop_timer_expired, CONNECT_ONE_SHOT)

func _on_tank_fucking_exploded() -> void:
	tank.tank_model.hide()
	var game_over_scene: GameOverScene = \
		(load("res://scenes/entities/game_over_scene.tscn") as PackedScene).instantiate()
	game_over_scene.player = tank
	AudioManager.play_sound_at(tank.global_position, preload("res://audio/sfx/large_explosion.ogg"), 15.0)
	get_tree().root.add_child.call_deferred(game_over_scene)

func _on_missile_parried() -> void:
	_hitstop()

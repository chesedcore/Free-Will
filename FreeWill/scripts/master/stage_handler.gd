class_name StageHandler extends Node3D

signal tank_fucking_exploded

@export var ui: CombatUI
@export var enemies_list: EnemiesList
@export var tank: PlayerTank
@export var environment: Node3D
@export var weapons: Node3D


const HITSTOP_TIME := 0.4
const HITSTOP_SLOW_DOWN_FACTOR := 0.001

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_wire_up_signals()
	_setup_name_tracking()

var _is_under_hitstop := false

func _wire_up_signals() -> void:
	UIBus.missile_parried.connect(_on_missile_parried)
	tank.damaged.connect(_on_tank_damaged)
	tank.fucking_exploded.connect(_on_tank_fucking_exploded)
	EnemySignalBus.spawn_entity.connect(on_spawn_entity)
	EventBus.spawn_weaponry.connect(_on_spawn_weaponry)

func _setup_name_tracking() -> void:
	ui.set_tank(tank)
	var enemies := enemies_list.get_enemies()
	
	var entities := enemies 
	if environment:
		var grapple_points := get_tree().get_nodes_in_group("Grapple Points")
		entities = entities + grapple_points
	ui.track_these_entities(entities)

func _on_hitstop_timer_expired() -> void:
	Engine.time_scale = 1
	_is_under_hitstop = false

func _hitstop(factor_scale: float = 1.0) -> void:
	if _is_under_hitstop: return
	_is_under_hitstop = true
	Engine.time_scale = HITSTOP_SLOW_DOWN_FACTOR * factor_scale

	var hitstop_timer := get_tree().create_timer(HITSTOP_TIME, true, false, true)
	hitstop_timer.timeout.connect(_on_hitstop_timer_expired, CONNECT_ONE_SHOT)

func _on_spawn_weaponry(node: Node) -> void:
	weapons.add_child(node)

func _on_tank_fucking_exploded() -> void:
	tank_fucking_exploded.emit()

func _on_tank_damaged() -> void:
	_hitstop(2.0)

func mission_complete_screen()->void:
	var game_over_scene: GameOverScene = \
		(load("res://scenes/entities/game_over_scene.tscn") as PackedScene).instantiate()
	game_over_scene.player = tank
	game_over_scene.completed = true
	#get_tree().root.add_child.call_deferred(game_over_scene)
	add_child.call_deferred(game_over_scene)
	tank.freeze = true

func _on_missile_parried() -> void:
	_hitstop()


#gael: the entity is spawning
var bomb_count :int= 0
func on_spawn_entity(entity :Node3D)->void :
	if entity is Bomb:
		bomb_count+= 1
		entity.name = "Bomb" + str(bomb_count)
	add_child(entity)
	ui.track_these_entities([entity])

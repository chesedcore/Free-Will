class_name MissonHandler extends Node3D

#Gael: Worried about too many preload ill load an enemy only when we need it 
#const ENEMY_PLANE = preload("res://scenes/entities/enemies/enemy_plane.tscn")
#const ENEMY_BATTLE_SHIP = preload("res://scenes/entities/enemies/enemy_battle_ship.tscn")

@export var mission_title :MissionStatus.MISSION_TITLES

var standard_plane : Resource
var standard_boat : Resource

@export var stagehandler: StageHandler

const PLANESPAWNHEIGHT : float = 335
const BOATSPAWNHEIGHT : float = 3
@export var mission_end_dialog : String
@export var waves : Array[WaveResource]
@export var spawnpoints: Node3D

@export var enemies_list: EnemiesList

#wave count starts from 0 remember to increment in display 
var current_wave :int= 0
var enemy_count : int = 0

#temporary mission start logic
func _ready() -> void:
	await get_tree().create_timer(2).timeout
	spawn_wave()

var enemy_scenes :Dictionary[WaveResource.EnemyTypes,Resource] = {}

#func load_needed_enemy_scenes()->void:
	#for wave in waves:
		#for enemytype : WaveResource.EnemyTypes in wave.waveinfo.keys():
			#if !enemy_scenes.has(enemytype):
				#match enemytype:
					#WaveResource.EnemyTypes.StandardPlane:
						#enemy_scenes.set(enemytype, load("res://scenes/entities/enemies/enemy_plane.tscn"))
func spawn_wave()->void:
	if current_wave >= waves.size():
		end_mission()
	else:
		var wave : WaveResource = waves[current_wave]
		#play some dialog
		if not wave.spawn_dialog.is_empty():
			Dialogic.Inputs.block_input(100000)
			Dialogic.start(wave.spawn_dialog)
			await Dialogic.timeline_ended
		for enemytype : WaveResource.EnemyTypes in wave.waveinfo.keys():
			match enemytype:
				WaveResource.EnemyTypes.StandardPlane:
					#number of enemiies of the specificed tyoeeeee
					if !standard_plane:
							standard_plane = load("res://scenes/entities/enemies/enemy_plane.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy : EnemyPlane = standard_plane.instantiate()
						
						var spawnpoint :Node3D = spawnpoints.get_children().pick_random()
						new_enemy.position = spawnpoint.global_position
						var offset :Vector3= Vector3(randf_range(-100,100),0,randf_range(-100,100))
						new_enemy.position = spawnpoint.global_position +offset
						new_enemy.position.y = PLANESPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Enemy Plane " +str(i+1)
						enemies_list.airborne_enemies.add_child(new_enemy)
				WaveResource.EnemyTypes.StandardGunboat:
					if ! standard_boat:
						standard_boat = load("res://scenes/entities/enemies/enemy_battle_ship.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy : EnemyBattleship = standard_boat.instantiate()
						
						var spawnpoint :Node3D = spawnpoints.get_children().pick_random()
						var offset :Vector3= Vector3(randf_range(-50,50),0,randf_range(-50,50))
						new_enemy.position = spawnpoint.global_position +offset
						new_enemy.position.y = BOATSPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Enemy BattleShip " +str(i+1)
						enemies_list.seaborne_enemies.add_child(new_enemy)
			enemy_count += wave.waveinfo[enemytype]
		current_wave +=1
		stagehandler.ui.track_these_entities(enemies_list.get_enemies())
	

#maybe we can death noises here
func on_enemy_death()->void:
	enemy_count -= 1
	if enemy_count ==0:
		
		spawn_wave()
func end_mission()->void:
	Dialogic.Inputs.block_input(100000)
	Dialogic.start(mission_end_dialog)
	await Dialogic.timeline_ended
	if stagehandler.tank.is_dead == false:
		stagehandler.mission_complete_screen()
		MissionStatus.complete_mission(mission_title)

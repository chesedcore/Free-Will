class_name MissonHandler extends Node3D

const AUDIO_DIALOGUE_DIP: float = 5.0

#Gael: Worried about too many preload ill load an enemy only when we need it
#const ENEMY_PLANE = preload("res://scenes/entities/enemies/enemy_plane.tscn")
#const ENEMY_BATTLE_SHIP = preload("res://scenes/entities/enemies/enemy_battle_ship.tscn")

@export var ON_FUCKING_FIRE : bool = false
@export var scene_to_transition_to : String
@export var mission_music: AudioStreamPlayer

# enemies
var standard_plane : Resource
var standard_boat : Resource
var cargo_boat : Resource
var elite_plane : Resource
var super_elite_plane: Resource
var bomber_plane : Resource
var shark_carrier : Resource
@export var stagehandler: StageHandler

const PLANESPAWNHEIGHT : float = 670
const BOATSPAWNHEIGHT : float = 3
const BOMBERSPAWNHEIGHT : float = 2750
@export var act_end_dialog : String

@export var waves : Array[WaveResource]
@export var spawnpoints_og: Node3D

@export var enemies_list: EnemiesList


@export var transition: ColorRect

var tank : PlayerTank

#wave count starts from 0 remember to increment in display
var current_wave: int = 0
var enemy_count: int = 0

func wire_signals()->void:
	stagehandler.tank_fucking_exploded.connect(_on_tank_fucking_exploded)
	Dialogic.timeline_started.connect(lower_sfx_and_music)
	Dialogic.timeline_ended.connect(raise_sfx_and_music)
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument:String)->void:
	if argument == "no_fade":
		fadeout_time = 0.001
	if argument == "end":
		EventBus.change_game_container_to.emit(load(scene_to_transition_to).instantiate())




#temporary mission start logic
func _ready() -> void:
	wire_signals()
	#wanted the tank to start with some motion so uhhh yeahhhhh
	tank = stagehandler.tank
	tank.linear_velocity += tank.camera_gimbal.global_transform.basis.z * (tank.GUN_FIRE_FORCE *10)
	fade_in()
	await spawn_wave()
	mission_music.play()

var enemy_scenes :Dictionary[WaveResource.EnemyTypes,Resource] = {}

func _on_tank_fucking_exploded() -> void:
	tank.tank_model.hide()
	var game_over_scene := Registry.create_game_over()
	game_over_scene.player = tank
	game_over_scene.current_scene = get_scene_file_path()
	#this actually advances a wave upon death so gotta decrement by 1 BUT DONT INCREMENNT IF THE PLAYER DIES DURING STARTING DIALOG
	game_over_scene.current_wave_idx = current_wave
	if current_wave > 0 :

		game_over_scene.current_wave_idx -= 1
	AudioManager.play_sound_at(tank.global_position, preload("res://audio/sfx/large_explosion.ogg"), 15.0)
	add_child.call_deferred(game_over_scene)

#SPAWNCONSTS
const PLANESPAWNRADIUS: float = 50
const PLANESPAWNDISTANCE: float= 50
const BOATSPANWRADIUS : float = 300
const BOATSPAWNDISTANCE: float = 100
const BOMBERSPAWNRADIUS : float = 1000
const BOMBERSPAWNDISTANCE : float =500
const SHARKSPAWNDISTANCE : float = 500
const SHARKSPAWNRADIUS : float = 1000

func spawn_wave()->void:
	var spawnpoints  :Array[Node]= spawnpoints_og.get_children()
	if current_wave >= waves.size():
		end_mission()
	else:
		var wave : WaveResource = waves[current_wave]
		#play some dialog
		if not wave.spawn_dialog.is_empty():
			#Dialogic.Inputs.block_input(100000)
			Dialogic.start(wave.spawn_dialog)
			if current_wave == 0:

				await Dialogic.timeline_ended
		#ARTIFICALLY AWAIT THE FUCKING IFFTRACKER CRASHESSSSSSSS AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+++++++++++++++++++++++++
		await  get_tree().create_timer(.5).timeout
		for enemytype : WaveResource.EnemyTypes in wave.waveinfo.keys():
			match enemytype:
				WaveResource.EnemyTypes.StandardPlane:
					#number of enemiies of the specificed tyoeeeee
					if !standard_plane:
							print("loading plane")
							standard_plane = load("res://scenes/entities/enemies/enemy_plane.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy : EnemyPlane = standard_plane.instantiate()

						var spawnpoint :Node3D = spawnpoints.pick_random()
						#var pos : Vector3= get_valid_spawn_position(spawnpoint.global_position,PLANESPAWNRADIUS,PLANESPAWNDISTANCE)
						new_enemy.position = spawnpoint.position
						new_enemy.position.y = PLANESPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Enemy Plane " +str(i+1)
						new_enemy.ONFUCKINGFIRE = ON_FUCKING_FIRE
						enemies_list.airborne_enemies.add_child(new_enemy)

				WaveResource.EnemyTypes.StandardGunboat:
					if ! standard_boat:
						standard_boat = load("res://scenes/entities/enemies/enemy_battle_ship.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy : EnemyBattleship = standard_boat.instantiate()

						var spawnpoint :Node3D = spawnpoints.pick_random()
						spawnpoints.erase(spawnpoint)
						#var pos : Vector3= get_valid_spawn_position(spawnpoint.global_position,BOATSPANWRADIUS,BOATSPAWNDISTANCE)
						new_enemy.position = spawnpoint.global_position
						new_enemy.position.y = BOATSPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Enemy BattleShip " +str(i+1)
						enemies_list.seaborne_enemies.add_child(new_enemy)
				WaveResource.EnemyTypes.Cargoboat:
					if ! cargo_boat:
						cargo_boat = load("res://scenes/entities/enemies/enemy_cargoship.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy : EnemyCargoShip = cargo_boat.instantiate()

						var spawnpoint :Node3D = spawnpoints.pick_random()
						spawnpoints.erase(spawnpoint)
						#var pos : Vector3= get_valid_spawn_position(spawnpoint.global_position,BOATSPANWRADIUS,BOATSPAWNDISTANCE)
						new_enemy.position = spawnpoint.global_position
						new_enemy.position.y = BOATSPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Enemy ShieldShip " +str(i+1)
						enemies_list.seaborne_enemies.add_child(new_enemy)
				WaveResource.EnemyTypes.ElitePlane:
					if ! elite_plane:
						elite_plane = load("res://scenes/entities/enemies/enemy_elite_plane.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy : EnemyPlane = elite_plane.instantiate()

						var spawnpoint :Node3D = spawnpoints.pick_random()
						#var pos : Vector3= get_valid_spawn_position(spawnpoint.global_position,PLANESPAWNRADIUS,PLANESPAWNDISTANCE)
						new_enemy.position =spawnpoint.position
						new_enemy.position.y = PLANESPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Enemy Elite Plane " +str(i+1)
						new_enemy.ONFUCKINGFIRE = ON_FUCKING_FIRE
						enemies_list.airborne_enemies.add_child(new_enemy)
				WaveResource.EnemyTypes.SuperElitePlane:
					#number of enemiies of the specificed tyoeeeee
					if !super_elite_plane:
							print("loading plane")
							super_elite_plane = load("res://scenes/entities/enemies/enemy_super_elite_plane.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy : SuperEnemyPlane= super_elite_plane.instantiate()

						var spawnpoint :Node3D = spawnpoints.pick_random()
						#var pos : Vector3= get_valid_spawn_position(spawnpoint.global_position,PLANESPAWNRADIUS,PLANESPAWNDISTANCE)
						new_enemy.position = spawnpoint.global_position
						new_enemy.position.y = PLANESPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Super Elite Enemy Plane " +str(i+1)
						#new_enemy.decoys_spawned.connect(stagehandler.ui.track_these_entities)
						new_enemy.ONFUCKINGFIRE = ON_FUCKING_FIRE
						enemies_list.airborne_enemies.add_child(new_enemy)
				WaveResource.EnemyTypes.BomberPlane:
					#number of enemiies of the specificed tyoeeeee
					if !bomber_plane:
							bomber_plane = load("res://scenes/entities/enemies/enemy_bomber_plane.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy :EnemyBomberPlane= bomber_plane.instantiate()

						var spawnpoint :Node3D = spawnpoints.pick_random()
						#var pos : Vector3= get_valid_spawn_position(spawnpoint.global_position,BOMBERSPAWNRADIUS,BOMBERSPAWNDISTANCE)
						new_enemy.position = spawnpoint.global_position
						new_enemy.position.y = BOMBERSPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Bomber Plane " +str(i+1)
						enemies_list.airborne_enemies.add_child(new_enemy)
				WaveResource.EnemyTypes.SharkCarrier:
					#number of enemiies of the specificed tyoeeeee
					if !shark_carrier:
							shark_carrier = load("res://scenes/entities/enemies/enemy_shark_carrier.tscn")
					for i in range(wave.waveinfo[enemytype]):
						var new_enemy :EnemySharkCarrier= shark_carrier.instantiate()

						var spawnpoint :Node3D = spawnpoints.pick_random()
						spawnpoints.erase(spawnpoint)
						#var pos : Vector3= get_valid_spawn_position(spawnpoint.global_position,SHARKSPAWNRADIUS,SHARKSPAWNDISTANCE)
						new_enemy.position = spawnpoint.global_position
						new_enemy.position.y = BOATSPAWNHEIGHT
						new_enemy.died.connect(on_enemy_death)
						new_enemy.name = "Shark Carrier " +str(i+1)
						new_enemy.ONFUCKINGFIRE = ON_FUCKING_FIRE
						enemies_list.seaborne_enemies.add_child(new_enemy)
			enemy_count += wave.waveinfo[enemytype]
		current_wave +=1
		var enemies := enemies_list.get_enemies()
		stagehandler.ui.track_these_entities(enemies)


const BORDER : float = 2500

func get_valid_spawn_position(base_pos: Vector3, radius: float, min_distance: float, max_attempts := 20) -> Vector3:
	for i in range(max_attempts):
		var offset : Vector3= Vector3(
			randf_range(-radius, radius),
			0,
			randf_range(-radius, radius)
		)
		var candidate : Vector3 = base_pos + offset
		if  abs(candidate.x)>= BORDER or abs(candidate.z)>= BORDER:
			continue
		var is_valid := true
		var entites : Array[Node] = enemies_list.get_enemies()

		for entity in entites:
			if entity.global_position.distance_to(candidate) < min_distance:
				is_valid = false
				break

		if is_valid:
			#print(candidate)
			return candidate

	return base_pos



#maybe we can death noises here
func on_enemy_death()->void:
	enemy_count -= 1
	if ! Dialogic.current_timeline and randi_range(1,100)<= 40:
		CriesOfTormentedSouls.play_random_noise()
	if enemy_count == 0:
		spawn_wave()

func end_mission() -> void:
	if Dialogic.current_timeline:
		await Dialogic.timeline_ended
	Dialogic.start(act_end_dialog)
	await Dialogic.timeline_ended
	if stagehandler.tank.is_dead == false:
		await fade_out()
		#if enviorment:
			#var grapple_points : Array[Node] = get_tree().get_nodes_in_group("Grapple Points")
			#for point in grapple_points:
				#IFFTracker.stop_tracking_entity(point)
		EventBus.change_game_container_to.emit(load(scene_to_transition_to).instantiate())


func fade_in()->void:
	var fade_in_tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	fade_in_tween.tween_property(transition,"modulate",Color("ffffff00"),2)
var fadeout_time : float= 1.0
func fade_out()->void:
	var fade_out_tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	fade_out_tween.tween_property(transition,"modulate",Color("ffffff"),fadeout_time)
	await fade_out_tween.finished


func lower_sfx_and_music()->void :
	var bus_index : int= AudioServer.get_bus_index("Audio Ducking")
	AudioServer.set_bus_volume_db(bus_index, -AUDIO_DIALOGUE_DIP)

func raise_sfx_and_music()->void :
	var bus_index : int= AudioServer.get_bus_index("Audio Ducking")
	AudioServer.set_bus_volume_db(bus_index, 0.)

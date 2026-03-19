class_name MissonHandler extends Node3D
const ENEMY_PLANE = preload("res://scenes/entities/enemies/enemy_plane.tscn")
@export var stagehandler: StageHandler

const PLANESPAWNHIEGHT : float = 335

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

func spawn_wave()->void:
	if current_wave >= waves.size():
		end_mission()
	else:
		var wave : WaveResource = waves[current_wave]
		for enemytype : WaveResource.EnemyTypes in wave.waveinfo.keys():
			match enemytype:
				WaveResource.EnemyTypes.StandardPlane:
					#number of enemiies of the specificed tyoeeeee
					for i in range(wave.waveinfo[enemytype]):
						
						var new_enemy :EnemyPlane = ENEMY_PLANE.instantiate()
						
						var spawnpoint :Node3D = spawnpoints.get_children().pick_random()
						new_enemy.position = spawnpoint.global_position
						new_enemy.position.y = PLANESPAWNHIEGHT
						new_enemy.died.connect(on_enemy_death)
						enemies_list.airborne_enemies.add_child(new_enemy)
			enemy_count += wave.waveinfo[enemytype]
		current_wave +=1
		stagehandler.ui.track_these_entities(enemies_list.get_enemies())
	

#maybe we can death noises here
func on_enemy_death()->void:
	enemy_count -= 1
	if enemy_count ==0:
		#temporary wave wait logic if we dont have a aait we get an error trying to track a freed plane
		await get_tree().create_timer(2).timeout
		spawn_wave()
func end_mission()->void:
	print("mission end")

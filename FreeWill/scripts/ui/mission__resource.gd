class_name MissionResource extends Resource


@export var mission_title : MissionStatus.MISSION_TITLES
@export var mission_name : String 
@export var is_unlocked :bool = false
@export var prerequisite_missions : Array[MissionStatus.MISSION_TITLES]
@export var mission_scene_path : String



func check_unlock()->void:

	var status : MissionStatus.Statuses =  MissionStatus.Statuses.Unlocked
	for mission: MissionStatus.MISSION_TITLES in prerequisite_missions:
		if MissionStatus.missions.has(mission):
			if  MissionStatus.missions.get(mission) == MissionStatus.Statuses.Completed:
				continue
		status = MissionStatus.Statuses.Locked
		break
	if status == MissionStatus.Statuses.Unlocked:
		is_unlocked = true
		MissionStatus.unlock_mission(mission_title)

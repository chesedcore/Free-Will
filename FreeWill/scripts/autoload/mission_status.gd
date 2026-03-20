extends Node


enum Statuses{Locked,Unlocked,Completed}
enum MISSION_TITLES {TEST,TESTSCENE,Act1Mission1}
var missions : Dictionary[MISSION_TITLES,Statuses]={
	MISSION_TITLES.TEST : Statuses.Unlocked,
	MISSION_TITLES.Act1Mission1: Statuses.Unlocked,
	MISSION_TITLES.TESTSCENE: Statuses.Locked
	
	
}

func check_unlock(key: MISSION_TITLES)->bool:
	if missions.has(key):
		if missions.get(key) == Statuses.Unlocked or missions.get(key) == Statuses.Completed:
			return true
	return false

func complete_mission(key : MISSION_TITLES)->void:
	if missions.has(key):
		missions.set(key,Statuses.Completed)

func unlock_mission(key : MISSION_TITLES)->void:
	if missions.has(key):
		missions.set(key,Statuses.Unlocked)

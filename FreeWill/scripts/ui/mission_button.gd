extends Button

@export var mission_info :MissionResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = mission_info.mission_name
	setup()
	if !mission_info.is_unlocked:
		disabled = true

	
func setup()->void:
		#first check its been unlocked in the inspector
	if ! mission_info.is_unlocked:
		#check if the status is unlocked in the autoload
		if !MissionStatus.check_unlock(mission_info.mission_title):
			mission_info.check_unlock()
		else :
			mission_info.is_unlocked = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pressed() -> void:
	
	get_tree().change_scene_to_file(mission_info.mission_scene_path)

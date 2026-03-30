extends Node

var all_sounds: Array[AudioStream] = []
var dupe_sounds: Array[AudioStream] = []


func _ready() -> void:
	_init_sounds()


func _init_sounds()->void:
	if all_sounds.is_empty():
		var dir : DirAccess= DirAccess.open("res://audio/Exported Voicelines/Mooks/death voicelines/")
		if dir:
			dir.list_dir_begin()
			var file :String = dir.get_next()

			while file != "":
				if file.ends_with(".wav") or file.ends_with(".ogg"):
					all_sounds.append(load("res://audio/Exported Voicelines/Mooks/death voicelines/" + file))
				file = dir.get_next()


func _refill()->void:
	dupe_sounds = all_sounds.duplicate()
	dupe_sounds.shuffle()


func play_random_noise() -> void:
	if dupe_sounds.is_empty():
		_refill()

	var sound: AudioStream = dupe_sounds.pop_back()
	var bus_index : int = AudioServer.get_bus_index("Voice")
	var curr_voice_db : = AudioServer.get_bus_volume_db(bus_index)
	AudioManager.play_death_noise(sound, curr_voice_db + 2,"Voice",false)

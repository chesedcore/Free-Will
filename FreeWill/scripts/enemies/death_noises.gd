extends Node

var all_sounds: Array[AudioStream] = []

var dupe_sounds: Array[AudioStream] = []
var is_playing :bool = false
var new_sound_player : AudioStreamPlayer
func _ready() -> void:
	
	new_sound_player =  AudioStreamPlayer.new()
	new_sound_player.finished.connect(on_done_playing)
	new_sound_player.bus = "Voice"
	add_child(new_sound_player)
	Dialogic.timeline_started.connect(stop_playing)
	_init_sounds()

func stop_playing()->void:
	if is_playing:
		new_sound_player.stop()
		is_playing = false

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

func on_done_playing()->void:
	is_playing = false

func play_random_noise() -> void:
	if ! is_playing:
		is_playing = true
		if dupe_sounds.is_empty():
			_refill()

		var sound: AudioStream = dupe_sounds.pop_back()
		var bus_index : int = AudioServer.get_bus_index("Voice")
		var curr_voice_db : = AudioServer.get_bus_volume_db(bus_index)
		new_sound_player.stream = sound
		new_sound_player.volume_db = curr_voice_db + 2
		new_sound_player.play()
		

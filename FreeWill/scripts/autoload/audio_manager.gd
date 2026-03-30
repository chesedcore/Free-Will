extends Node

## AudioManager class.


func is_playing_voice() -> bool:
	var players: Array[AudioStreamPlayer]
	players.assign(get_children())
	for player in players:
		if player.bus == "Voice": return true
	return false
	

func play_sound_at(position: Vector3, sound: AudioStream, volume_db: float = 0.0, randomize_pitch: bool = true) -> void:
	var new_sound_player := AudioStreamPlayer3D.new()

	new_sound_player.bus = "SFX"
	new_sound_player.attenuation_filter_cutoff_hz = 20000

	if (randomize_pitch):
		new_sound_player.pitch_scale = randf_range(0.92, 1.13)

	new_sound_player.stream = sound
	new_sound_player.volume_db = volume_db
	new_sound_player.finished.connect(new_sound_player.queue_free)

	add_child(new_sound_player)
	new_sound_player.position = position

	if (new_sound_player.global_position != Vector3(NAN, NAN, NAN)):
		new_sound_player.play()


func play_sound(sound: AudioStream, volume_db: float = 0.0, bus: String = "SFX",randomize_pitch: bool = true) -> void:
	var new_sound_player := AudioStreamPlayer.new()

	new_sound_player.bus = bus

	if (randomize_pitch):
		new_sound_player.pitch_scale = randf_range(0.92, 1.13)

	new_sound_player.stream = sound
	new_sound_player.volume_db = volume_db
	new_sound_player.finished.connect(new_sound_player.queue_free)

	add_child(new_sound_player)
	new_sound_player.play()

func play_death_noise(sound: AudioStream, volume_db: float = 0.0, bus: String = "SFX",randomize_pitch: bool = true) -> void:
	if is_playing_voice(): return
	play_sound(sound, volume_db, bus, randomize_pitch)

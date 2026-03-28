class_name SoundSettings extends OptionsPanel

@export var master_slider: HSlider
@export var sfx_slider: HSlider
@export var voice_slider: HSlider
@export var music_slider: HSlider
@export var wind_slider: HSlider

func _wire_up_signals() -> void:
	master_slider.value_changed.connect(_on_master_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	voice_slider.value_changed.connect(_on_voice_changed)
	music_slider.value_changed.connect(_on_music_changed)
	wind_slider.value_changed.connect(_on_wind_changed)

func _init_state() -> void:
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	voice_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voice")))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	wind_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Wind")))

func _ready() -> void:
	_wire_up_signals()
	_init_state()

func _on_master_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_voice_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear_to_db(value))

func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_wind_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Wind"), linear_to_db(value))

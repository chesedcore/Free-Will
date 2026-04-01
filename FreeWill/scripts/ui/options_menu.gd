class_name OptionsMenu extends OptionsPanel

@export var trash: Control
@export var sounds: PauseMenuButton
@export var keybinds: PauseMenuButton
@export var leave: PauseMenuButton
@export var callouts: PauseMenuButton
@export var cascade_v_2: CascadeV2
@export var fullscreen: PauseMenuButton

var pane: OptionsPanel

func _ready() -> void:
	setup_callouts()
	_wire_up_signals()

func setup_callouts() -> void:
	if EventBus.callout_enabled:
		callouts.original_text = "disable callouts"
		callouts.text = "disable callouts"
		callouts.undershadow_text.text = "disable callouts"
	else:
		callouts.original_text = "enable callouts"
		callouts.text = "enable callouts"
		callouts.undershadow_text.text = "enable callouts"

func _wire_up_signals() -> void:
	sounds.clicked.connect(_on_sounds_clicked)
	keybinds.clicked.connect(_on_keybinds_clicked)
	leave.clicked.connect(_on_leave_clicked)
	callouts.clicked.connect(_on_callouts_clicked)
	fullscreen.clicked.connect(_on_toggle_fullscreen)

func throw_away_existing_pane() -> void:
	
	#if there's no pane, there's nothing to throw away
	if not pane: return
	
	pane.pop_in()
	pane.reparent(trash)
	pane.t.finished.connect(pane.queue_free)
	pane = null

func summon_panel(panel: OptionsPanel) -> void:
	throw_away_existing_pane()
	pane = panel
	add_child(pane)
	panel.pop_out()

func _on_sounds_clicked() -> void:
	summon_panel(Registry.create_sound_settings())

func _on_keybinds_clicked() -> void:
	summon_panel(Registry.create_keybind_settings())

func _on_callouts_clicked() -> void:
	EventBus.callout_enabled = not EventBus.callout_enabled
	setup_callouts()

func _on_toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_leave_clicked() -> void:
	throw_away_existing_pane()
	cascade_v_2.cascade_out()
	cascade_v_2.cascade_out_chain_finished.connect(self.queue_free)

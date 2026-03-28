class_name OptionsMenu extends OptionsPanel

@export var trash: Control
@export var sounds: PauseMenuButton
@export var keybinds: PauseMenuButton
@export var leave: PauseMenuButton
@export var cascade_v_2: CascadeV2

var pane: OptionsPanel

func _ready() -> void:
	_wire_up_signals()

func _wire_up_signals() -> void:
	sounds.clicked.connect(_on_sounds_clicked)
	keybinds.clicked.connect(_on_keybinds_clicked)
	leave.clicked.connect(_on_leave_clicked)

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

func _on_leave_clicked() -> void:
	throw_away_existing_pane()
	cascade_v_2.cascade_out()
	cascade_v_2.cascade_out_chain_finished.connect(self.queue_free)

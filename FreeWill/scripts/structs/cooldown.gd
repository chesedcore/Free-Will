class_name Cooldown extends Timer

var duration: float

static func from_time(cooldown_duration: float, bind_to_node: Node) -> Cooldown:
	var cd := new()
	cd.duration = cooldown_duration
	cd.one_shot = true
	bind_to_node.add_child(cd)
	return cd

func start_cooldown() -> void:
	start(duration)

##checks if this timer has fully cooled down. (fully finished ticking)
func is_ready() -> bool:
	return is_stopped()

##checks if this timer is still ticking.
func is_active() -> bool:
	return not is_stopped()

func add_time(extra_time: float) -> void:
	if not is_stopped():
		start(time_left + extra_time)

func get_normalised_progress() -> float:
	if duration <= 0.0 or is_stopped():
		return 1.0
	return 1.0 - (time_left / duration)

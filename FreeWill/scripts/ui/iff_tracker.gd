class_name IFFTracker

static var _tracked_entities: Dictionary[PhysicsBody3D, IFF]

@export var font_size: int = 14
@export var text_colour := Color.WHITE
@export var outline_colour := Color.BLACK
@export var outline_size := 2
@export var scale_modifier := 0.3

## Do not access this directly, use the get_lock_this_frame() function for error handling
static var _locked_entity: PhysicsBody3D

var camera: Camera3D
var attached_control: Control

const LOCKON_RANGE_SQ := pow(1250, 2)

static func new_iff(with_name: String) -> IFF:
	var iff := preload("res://scenes/ui/IFF.tscn").instantiate() as IFF
	iff.set_iff(with_name)
	iff.iff_tracked_name = with_name
	return iff

static func from_control(control: Control) -> IFFTracker:
	assert(control, "That control isn't valid!")
	var tags := new()
	var cam := control.get_viewport().get_camera_3d()
	tags.attached_control = control
	tags.camera = cam
	return tags

static func get_lock_this_frame() -> Option:
	if not _locked_entity:
		return Option.None()

	return Option.Some(_locked_entity)

static func stop_tracking_entity(entity: PhysicsBody3D) -> void:
	if not _tracked_entities.has(entity): return

	var label := _tracked_entities[entity]
	label.queue_free()
	_tracked_entities.erase(entity)

	#clear lock if we were tracking this piece of shit
	if _locked_entity == entity:
		_locked_entity = null

static func clear_tracked_entities() -> void:
	_tracked_entities = {}

##add some entity to be tracked by a name
func track_entity(entity: PhysicsBody3D, with_name: String) -> void:
	assert(attached_control, "There's no control attached!")
	if _tracked_entities.has(entity): return

	var iff := new_iff(with_name)

	attached_control.add_child(iff)
	iff.scale *= scale_modifier
	_tracked_entities[entity] = iff

func tick(origin_body: PhysicsBody3D) -> void:

	camera = attached_control.get_viewport().get_camera_3d()
	if not camera: return

	for entity: PhysicsBody3D in _tracked_entities.keys():
		if not is_instance_valid(entity):
			push_warning("The entity %s with name %s isn't valid anymore, you forgot to clean it off" % [str(entity), _tracked_entities[entity]])
			continue
		update_entity(entity)

	if not _locked_entity:
		acquire_lock(origin_body)

	for entity: PhysicsBody3D in _tracked_entities.keys():
		if not is_instance_valid(entity): continue
		update_iff_state(entity, origin_body)

##idk man i was in the middle of a refactor and i lost the previous comment
##returns true if the entity's IFF was updated
func update_entity(entity: PhysicsBody3D) -> bool:
	var iff := _tracked_entities[entity]

	if not camera.is_position_in_frustum(entity.global_position):
		iff.visible = false
		if _locked_entity == entity:
			_locked_entity = null
		return false

	var screen_pos := camera.unproject_position(entity.global_position)

	iff.position = screen_pos
	iff.visible = true
	return true

func acquire_lock(origin_body: PhysicsBody3D) -> void:
	var best_candidate: PhysicsBody3D = null
	var best_distance_from_center := INF

	for entity: PhysicsBody3D in _tracked_entities.keys():
		if not is_instance_valid(entity): continue
		if not _tracked_entities[entity].visible: continue

		var eucl_distance_sq := origin_body.global_position.distance_squared_to(entity.global_position)
		if eucl_distance_sq >= LOCKON_RANGE_SQ: continue

		var screen_pos := camera.unproject_position(entity.global_position)
		var viewport_size := attached_control.get_viewport_rect().size
		var screen_center := viewport_size / 2.0
		var distance_from_center := screen_pos.distance_to(screen_center)

		if distance_from_center < best_distance_from_center:
			best_distance_from_center = distance_from_center
			best_candidate = entity

	if best_candidate:
		_locked_entity = best_candidate
		_tracked_entities[best_candidate].change_state(IFF.State.LOCKED_ON)

##manually cycle to the next available target
func cycle_lock(origin_body: PhysicsBody3D) -> void:
	var lockable_entities: Array[PhysicsBody3D] = []

	for entity: PhysicsBody3D in _tracked_entities.keys():
		if not is_instance_valid(entity): continue
		if not _tracked_entities[entity].visible: continue

		var eucl_distance_sq := origin_body.global_position.distance_squared_to(entity.global_position)
		if eucl_distance_sq < LOCKON_RANGE_SQ:
			lockable_entities.append(entity)

	if lockable_entities.is_empty():
		_locked_entity = null
		return

	#ugly ahh function to sort by how close shit is to the center of the screen
	lockable_entities.sort_custom(func(a: PhysicsBody3D, b: PhysicsBody3D) -> bool:
		var pos_a := camera.unproject_position(a.global_position)
		var pos_b := camera.unproject_position(b.global_position)
		var viewport_size := attached_control.get_viewport_rect().size
		var screen_center := viewport_size / 2.0
		return pos_a.distance_to(screen_center) < pos_b.distance_to(screen_center)
	)

	#get current idx and shift towards the next one
	if _locked_entity:
		var current_index := lockable_entities.find(_locked_entity)
		if current_index != -1:
			var next_index := (current_index + 1) % lockable_entities.size()
			_locked_entity = lockable_entities[next_index]
		else: _locked_entity = lockable_entities[0]
	else:
		_locked_entity = lockable_entities[0]

	_tracked_entities[_locked_entity].change_state(IFF.State.LOCKED_ON)

func update_iff_state(entity: PhysicsBody3D, origin: PhysicsBody3D) -> void:
	var iff := _tracked_entities[entity]
	if not iff.visible: return

	var eucl_distance_sq := origin.global_position.distance_squared_to(entity.global_position)

	if entity == _locked_entity:
		iff.change_state(IFF.State.LOCKED_ON)
	elif eucl_distance_sq < LOCKON_RANGE_SQ:
		iff.change_state(IFF.State.FOCUSED)
	else:
		iff.change_state(IFF.State.ON_SCREEN)

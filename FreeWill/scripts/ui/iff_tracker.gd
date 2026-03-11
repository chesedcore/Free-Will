class_name IFFTracker

var tracked_entities: Dictionary[PhysicsBody3D, IFF]

@export var font_size: int = 14
@export var text_colour := Color.WHITE
@export var outline_colour := Color.BLACK
@export var outline_size := 2
@export var scale_modifier := 0.3

var camera: Camera3D
var attached_control: Control

static func new_iff(with_name: String) -> IFF:
	var iff := preload("res://scenes/ui/IFF.tscn").instantiate() as IFF
	iff.set_iff(with_name)
	return iff

static func from_control(control: Control) -> IFFTracker:
	assert(control, "That control isn't valid!")
	var tags := new()
	var cam := control.get_viewport().get_camera_3d()
	tags.attached_control = control
	tags.camera = cam
	return tags

##add some entity to be tracked by a nametag
func track_entity(entity: PhysicsBody3D, with_name: String) -> void:
	assert(attached_control,  "There's no control attached!")
	if tracked_entities.has(entity): return
	
	var iff := new_iff(with_name)
	
	attached_control.add_child(iff)
	iff.scale *= scale_modifier
	tracked_entities[entity] = iff

func stop_tracking_entity(entity: PhysicsBody3D) -> void:
	if not tracked_entities.has(entity): return
	
	var label := tracked_entities[entity]
	label.queue_free()
	tracked_entities.erase(entity)

func tick() -> void:
	if not camera: return
	
	for entity in tracked_entities:
		if not is_instance_valid(entity):
			push_warning("The entity %s with name %s isn't valid anymore, you forgot to clean it off" % [str(entity), tracked_entities[entity]])
			return
		
		if not update_entity(entity): continue

##returns true if that entity was updated, else false.
func update_entity(entity: PhysicsBody3D) -> bool:
	
	var label := tracked_entities[entity]
	
	var entity_pos_in_camera_space := camera.global_basis.inverse() * (entity.global_position - camera.global_position)
	
	if entity_pos_in_camera_space.z > 0:
		#if entity is behind camera^
		label.visible = false
		return false
	
	var screen_pos := camera.unproject_position(entity.global_position)
	
	
	label.position = screen_pos
	label.visible = true
	return true

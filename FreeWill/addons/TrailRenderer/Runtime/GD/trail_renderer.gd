class_name TrailRenderer
extends Node3D

enum Alignment { VIEW, TRANSFORM_Z, STATIC }
enum TextureMode { STRETCH, TILE, PER_SEGMENT }

@export var lifetime: float = 1.0
@export var min_vertex_distance: float = 0.5
@export var is_emitting: bool = true
@export var curve: Curve
@export var alignment: Alignment = Alignment.TRANSFORM_Z
@export var world_space: bool = true

@export_group("Appearance")
@export var material: Material
@export var cast_shadows: GeometryInstance3D.ShadowCastingSetting = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
@export var texture_mode: TextureMode = TextureMode.STRETCH

#the old system used the fucking Point system to store data because Godot
#doesn't have a Struct feature. wow!!! thanks a lot godot!!! fucking stupid ass
#piece of shit engine. i hate you. i hate this engine to all eternity.
#"just make object lean" JUAN LINIETSKY PLEASE I AM TRYING TO MAKE A GAME
#GIVE ME ACTUAL FUCKING COPY TYPES I BEG OF YOU OH MY GOD

var _positions: Array[Vector3] = []
var _align_vecs: Array[Vector3] = []
var _times: Array[float] = []
var _tex_offsets: Array[float] = []

var _head: int = 0
var _count: int = 0
var _accum_time: float = 0.0

#i've decided to replace ImmMesh with ArrayMesh, something with OpenGL simulations being 
#fucking terrible for vulkan enabled modern CPUs. go figure
var _mesh: ArrayMesh = ArrayMesh.new()
var _mesh_instance: MeshInstance3D
var _dirty: bool = false
#  ^^^^^^^^ a modern invention you can't DREAM of!! a DIRTY FLAG to not update your piece of shit 
#           immediate mesh EVERY SINGLE FUCKING FRAME AHAHAHAHA SOMEBODY FUCKING KILL ME AHAHAHAHAHAH


var _last_emitting_state: bool = false
var _last_spawn_point: Vector3
var _camera: Camera3D

# ===============THE PAIN BEGINS==========================================

func _ready() -> void:
	if curve == null:
		curve = Curve.new()
		curve.add_point(Vector2(0.0, 0.5))
		curve.add_point(Vector2(1.0, 0.5))

	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)

	_mesh_instance.mesh = _mesh
	_mesh_instance.material_override = material
	_mesh_instance.top_level = true
	#             #^^^^^^^^^^^^^^^^ might need to rethink this down the line
	_mesh_instance.cast_shadow = cast_shadows

	_last_spawn_point = global_position
	_last_emitting_state = is_emitting



func _physics_process(delta: float) -> void:
	
	#var start := Time.get_ticks_usec()
	
	_accum_time += delta

	if _camera == null:
		_camera = get_viewport().get_camera_3d()

	#edge starts here
	if not _last_emitting_state and is_emitting:
		if _count == 0:
			_add_point(global_position)
			_add_point(global_position)

	_last_emitting_state = is_emitting

	#isn't the loop a lloooooot cleaner now :)
	if is_emitting:
		if _last_spawn_point.distance_to(global_position) > min_vertex_distance:
			_add_point(global_position, global_basis.x.normalized(), _accum_time)
			_last_spawn_point = global_position
		elif _count > 0:
			_set_position(_count - 1, global_position)
			_set_alignment(_count - 1, global_basis.x)
	
	#jesse what the fuck is garbage collection
	_prune()
	
	if _count < 2:
		if _mesh.get_surface_count() > 0:
			_mesh.clear_surfaces()
		return
	
	#only rebuild mesh when something changed. NOT EVERY FRAME
	if _dirty:
		_rebuild_mesh()
		_dirty = false
	
	#var end := Time.get_ticks_usec()
	#print((end-start)/1000.0, " ms |", get_parent().get_parent().name, "NEW TRAILS")


# PIECES OF SHIT TO EMULATE STRUCT METHODS BECAUSE FUCK YOU JUAN LINIETSKY
# FUCK YOU VNEN
# FUCK YOU GDSCRIPT TEAM. FUCK YOU GODOT CORE
# AFTER THIS JAM ENDS I'M GOING TO REWRITE FUCKING CORE MYSELF
# I FUCKING HATE YOUR SHITASS BUREAUCRATIC DECISIONS
# GIVE ME STRUCTS. OR GIVE ME BLOOD

func _idx(i: int) -> int:
	return _head + i

func _add_point(pos: Vector3, align: Vector3 = Vector3.FORWARD, t: float = -1.0) -> void:
	if t < 0.0:
		t = _accum_time

	_positions.append(pos)
	_align_vecs.append(align.normalized())
	_times.append(t)
	_tex_offsets.append(0.0)

	_count += 1
	_dirty = true

func _set_position(i: int, pos: Vector3) -> void:
	_positions[_idx(i)] = pos
	_dirty = true

func _set_alignment(i: int, align: Vector3) -> void:
	_align_vecs[_idx(i)] = align
	_dirty = true

func _remove_front() -> void:
	_head += 1
	_count -= 1
	_dirty = true

#waltah. dont pop front in a frame routine waltah
func _prune() -> void:
	while _count > 0 and _accum_time >= _times[_idx(0)] + lifetime:
		_remove_front()

	_update_tex()

# i might be going CRAAZY AHAHAHAHHA

func _update_tex() -> void:
	if _count < 2:
		return

	match texture_mode:
		TextureMode.STRETCH:
			for i: int in _count:
				_tex_offsets[_idx(i)] = float(i) / float(_count - 1)

		TextureMode.TILE:
			var acc: float = 0.0
			for i: int in _count:
				if i == 0:
					_tex_offsets[_idx(i)] = 0.0
				else:
					acc += _positions[_idx(i - 1)].distance_to(_positions[_idx(i)])
					_tex_offsets[_idx(i)] = acc

		TextureMode.PER_SEGMENT:
			for i: int in _count:
				_tex_offsets[_idx(i)] = float(i)

# please work

func _rebuild_mesh() -> void:
	_mesh.clear_surfaces()

	var v_count: int = _count * 2

	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var indices: PackedInt32Array = PackedInt32Array()

	vertices.resize(v_count)
	normals.resize(v_count)
	uvs.resize(v_count)

	var align_vec: Vector3

	if alignment == Alignment.VIEW and world_space:
		align_vec = _camera.global_basis.z.normalized()
	elif alignment == Alignment.TRANSFORM_Z and world_space:
		align_vec = global_basis.z.normalized()

	for i: int in _count:
		var cur: Vector3 = _positions[_idx(i)]

		var tangent: Vector3
		if i == 0:
			tangent = cur.direction_to(_positions[_idx(1)])
		elif i == _count - 1:
			tangent = _positions[_idx(i - 1)].direction_to(cur)
		else:
			var prev: Vector3 = _positions[_idx(i - 1)]
			var next: Vector3 = _positions[_idx(i + 1)]
			tangent = (prev.direction_to(cur) + cur.direction_to(next)) * 0.5

		tangent = tangent.normalized()

		var a_vec: Vector3 = align_vec if alignment != Alignment.STATIC else _align_vecs[_idx(i)]

		var bitangent: Vector3 = a_vec.cross(tangent).normalized()
		var normal: Vector3 = tangent.cross(bitangent).normalized()
		#^^^^^ consideration, why the fuck are we doing this every frame when we could just
		#call it a day with a ribbon billboard or some similar crap

		var width: float = curve.sample(float(i) / float(_count - 1))
		bitangent *= width * 0.5

		var base: int = i * 2

		vertices[base] = cur - bitangent
		vertices[base + 1] = cur + bitangent

		normals[base] = normal
		normals[base + 1] = normal

		var tex: float = _tex_offsets[_idx(i)]
		uvs[base] = Vector2(0.0, 1.0 - tex)
		uvs[base + 1] = Vector2(1.0, 1.0 - tex)

	for i: int in _count - 1:
		var a: int = i * 2
		var b: int = a + 1
		var c: int = (i + 1) * 2
		var d: int = c + 1
		
		indices.append(a)
		indices.append(b)
		indices.append(c)
		
		indices.append(c)
		indices.append(b)
		indices.append(d)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mesh.surface_set_material(0, material)

	_mesh_instance.mesh = _mesh
	_mesh_instance.global_transform = Transform3D.IDENTITY if world_space else global_transform

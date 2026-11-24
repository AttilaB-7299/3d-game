extends Node3D
class_name Chunk

var mesh_instance: MeshInstance3D
var should_remove := true
var heights := PackedFloat32Array()

const HEIGHT_CAP := 10.0
const HEIGHT_MIN := -4.0
const HEIGHT_SCALE := 45.0
const HEIGHT_JITTER := 0.0
const LIGHT_DIR := Vector3(0.5, 0.8, 0.3) # direction pointing toward the light


func _init() -> void:
	pass


# One height function used by the mesh, collision, and the instance placement
func get_height(noise: FastNoiseLite, wx: float, wz: float) -> float:
	var n := noise.get_noise_2d(wx, wz) # -1..1
	var shaped := signf(n) * pow(absf(n), 1.6) #1.6# flatter valleys, sharper peaks
	return shaped * HEIGHT_SCALE


func setup(_noise: FastNoiseLite, _x: int, _z: int, _chunk_size: int, _map_data: PackedFloat32Array, verts_per_side: int, step: float):
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = build_lowpoly_mesh(_noise, _x, _z, _chunk_size, verts_per_side)

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	mat.metallic_specular = 0.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat

	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)

	#generate(100, 100, 100, 5, "Bushes", "null", _noise, _x, _z, _chunk_size, false)
	generate(3, 3, 3, 1, "Trees", "Capsule", _noise, _x, _z, _chunk_size, true)
	#generate(10, 3, 10, 300, "Grass", "null", _noise, _x, _z, _chunk_size, false)
	#generate(100, 100, 100, 5, "Ferns", "Circle", _noise, _x, _z, _chunk_size, false)

	# Collision uses the same heights as the visible mesh
	var height_shape := HeightMapShape3D.new()
	height_shape.map_width = verts_per_side
	height_shape.map_depth = verts_per_side
	height_shape.map_data = heights

	var col_shape := CollisionShape3D.new()
	col_shape.shape = height_shape
	col_shape.scale = Vector3(step, 1.0, step)

	var static_body := StaticBody3D.new()
	static_body.add_child(col_shape)
	add_child(static_body)


func build_lowpoly_mesh(_noise: FastNoiseLite, _x: int, _z: int, _chunk_size: int, verts_per_side: int) -> ArrayMesh:
	var half := _chunk_size * 0.5
	var step := float(_chunk_size) / float(verts_per_side - 1)

	var jitter_rng := RandomNumberGenerator.new()
	jitter_rng.seed = hash(Vector2i(_x, _z)) + 1

	# 1. Build the grid of heights (jitter heights only, never positions)
	heights.clear()
	var grid: Array[Vector3] = []
	for iz in range(verts_per_side):
		for ix in range(verts_per_side):
			var px := -half + ix * step
			var pz := -half + iz * step
			var is_edge := ix == 0 or iz == 0 or ix == verts_per_side - 1 or iz == verts_per_side - 1

			var h := get_height(_noise, px + _x, pz + _z)
			if not is_edge: # edges stay un-jittered so chunks meet cleanly
				h += jitter_rng.randf_range(-HEIGHT_JITTER, HEIGHT_JITTER)

			grid.append(Vector3(px, h, pz))
			heights.append(h)

	# 2. Turn each grid square into 2 separate triangles
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var color_rng := RandomNumberGenerator.new()
	color_rng.seed = hash(Vector2i(_x, _z))

	for iz in range(verts_per_side - 1):
		for ix in range(verts_per_side - 1):
			var a := grid[iz * verts_per_side + ix]
			var b := grid[iz * verts_per_side + ix + 1]
			var c := grid[(iz + 1) * verts_per_side + ix]
			var d := grid[(iz + 1) * verts_per_side + ix + 1]
			_add_face(st, a, b, c, color_rng)
			_add_face(st, b, d, c, color_rng)

	st.generate_normals() # vertices aren't shared, so normals are flat
	return st.commit()


func _add_face(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, rng: RandomNumberGenerator) -> void:
	# base color from the triangle's average height
	var avg_h := (a.y + b.y + c.y) / 3.0
	var t := clampf(inverse_lerp(-20.0, 30.0, avg_h), 0.0, 1.0)

	var low_color := Color(0.546, 0.871, 0.341, 1.0)
	var mid_color := Color(0.407, 0.696, 0.301, 1.0)
	var high_color := Color(0.449, 0.626, 0.385, 1.0)

	var col: Color
	if t < 0.5:
		col = low_color.lerp(mid_color, t * 2.0)
	else:
		col = mid_color.lerp(high_color, (t - 0.5) * 2.0)
	#else:
		#col = mid_color.lerp(high_color, (t - 0.7) * 2.0)
	# shade by the direction the face points
	var n := (c - a).cross(b - a).normalized()
	var light := clampf(n.dot(LIGHT_DIR.normalized()), 0.0, 1.0)
	var shade := lerpf(0.55, 1.15, light)
	col = Color(col.r * shade, col.g * shade, col.b * shade)

	# per-triangle variation
	col = col.lightened(rng.randf_range(-0.10, 0.10))

	for v in [a, b, c]:
		st.set_color(col)
		st.add_vertex(v)


func generate(x_scale: float, y_scale: float, z_scale: float, instance_count: int, node: String, coll_shape: String, _noise, chunk_world_x: float, chunk_world_z: float, _chunk_size: int, hasCollision: bool) -> void:
	var multimesh_inst = get_node_or_null(str(node))
	if not multimesh_inst:
		printerr(str(node) + " node not found!")
		return

	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = multimesh_inst.multimesh.mesh if multimesh_inst.multimesh else null
	multimesh_inst.multimesh = multimesh
	multimesh.instance_count = instance_count
	multimesh.custom_aabb = AABB(Vector3(-_chunk_size, -50.0, -_chunk_size), Vector3(_chunk_size * 2.0, 100.0, _chunk_size * 2.0))

	var half_size = _chunk_size * 0.5
	var placed = 0
	var attempts = 0

	while placed < instance_count and attempts < instance_count * 3:
		attempts += 1
		var local_x = randf_range(-half_size, half_size)
		var local_z = randf_range(-half_size, half_size)

		var height = get_height(_noise, local_x + chunk_world_x, local_z + chunk_world_z)

		if height > (HEIGHT_MIN) and height < HEIGHT_CAP:
			var t = Transform3D()
			t.origin = Vector3(local_x, height, local_z)
			t = t.rotated_local(Vector3.UP, randf() * TAU)
			t = t.scaled_local(Vector3(x_scale, y_scale, z_scale))

			multimesh.set_instance_transform(placed, t)
			placed += 1

	multimesh.visible_instance_count = placed

	if hasCollision:
		var shape
		if coll_shape == "Circle":
			shape = SphereShape3D.new()
		else:
			shape = CapsuleShape3D.new()
			shape.height = 30.0

		for i in range(placed):
			var static_body = StaticBody3D.new()
			var collision_shape = CollisionShape3D.new()
			collision_shape.shape = shape
			static_body.transform = multimesh.get_instance_transform(i)
			static_body.add_child(collision_shape)
			multimesh_inst.add_child(static_body)

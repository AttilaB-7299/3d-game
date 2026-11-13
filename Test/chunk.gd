extends Node3D
class_name Chunk

var mesh_instance: MeshInstance3D
var should_remove := true
const HEIGHT_CAP := 10.0
const HEIGHT_MIN := -8.0

func _init() -> void:
	pass
func generate_foliage(_noise, chunk_world_x: float, chunk_world_z: float, _chunk_size: int) -> void:
	var multimesh_inst = get_node_or_null("MultiMeshInstance3D")
	if not multimesh_inst:
		printerr("MultiMeshInstance3D node not found!")
		return
		
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = multimesh_inst.multimesh.mesh if multimesh_inst.multimesh else null
	multimesh_inst.multimesh = multimesh
	
	var instance_count = 2
	multimesh.instance_count = instance_count
	multimesh.custom_aabb = AABB(Vector3(-_chunk_size, -50.0, -_chunk_size), Vector3(_chunk_size * 2.0, 100.0, _chunk_size * 2.0))
	
	var half_size = _chunk_size * 0.5
	var placed = 0
	var attempts = 0
	
	while placed < instance_count and attempts < instance_count * 5:
		attempts += 1
		var local_x = randf_range(-half_size, half_size)
		var local_z = randf_range(-half_size, half_size)
		
		var height = _noise.get_noise_2d(local_x + chunk_world_x, local_z + chunk_world_z) * 35.0
		
		if height > HEIGHT_MIN and height < HEIGHT_CAP:
			var t = Transform3D()
			t.origin = Vector3(local_x, height, local_z)
			t = t.rotated_local(Vector3.UP, randf() * TAU)
			
			var scale_factor = randf_range(400.0, 1000.0)
			t = t.scaled_local(Vector3(scale_factor, scale_factor, scale_factor))
			
			multimesh.set_instance_transform(placed, t)
			placed += 1
			
	multimesh.visible_instance_count = placed
func setup(_noise: FastNoiseLite, _x: int, _z: int, _chunk_size: int, map_data: PackedFloat32Array, verts_per_side: int, step: float):
	var subdivisions := int(_chunk_size * 0.5)
	
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(_chunk_size, _chunk_size)
	plane_mesh.subdivide_depth = subdivisions
	plane_mesh.subdivide_width = subdivisions
	
	plane_mesh.material = preload("res://Test/terrain.material")
	var surface_tool := SurfaceTool.new()
	var data_tool := MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane := surface_tool.commit()
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex := data_tool.get_vertex(i)
		var height = _noise.get_noise_2d(vertex.x + _x, vertex.z + _z) * 35.0
		vertex.y = height
		data_tool.set_vertex(i, vertex)
		
		var t = inverse_lerp(HEIGHT_CAP, HEIGHT_MIN, height)
		t = clamp(t, 0.0, 1.0)
		
		var grass_color := Color(0.2, 0.6, 0.2)
		var stone_color := Color(0.45, 0.45, 0.45)
		data_tool.set_vertex_color(i, grass_color.lerp(stone_color, t))
	array_plane.clear_surfaces()
	data_tool.commit_to_surface(array_plane)
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
	generate_foliage(_noise, _x, _z, _chunk_size)	
	
	var height_shape := HeightMapShape3D.new()
	height_shape.map_width = verts_per_side
	height_shape.map_depth = verts_per_side
	height_shape.map_data = map_data
	
	var col_shape := CollisionShape3D.new()
	col_shape.shape = height_shape
	col_shape.scale = Vector3(step, 1.0, step)
	
	var static_body := StaticBody3D.new()
	static_body.add_child(col_shape)
	add_child(static_body)

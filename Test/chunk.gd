extends Node3D
class_name Chunk

var mesh_instance: MeshInstance3D
var should_remove := true
const HEIGHT_CAP := 45.0
const HEIGHT_MIN := 0.0

func _init() -> void:
	pass
func setup(_noise: FastNoiseLite, _x: int, _z: int, _chunk_size: int, map_data: PackedFloat32Array, verts_per_side: int, step: float):
	var subdivisions := (verts_per_side - 2) #int(_chunk_size * 0.5)
	
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
		
		var grass_color := Color(0.171, 0.702, 0.154, 1.0)
		var color2 := Color(0.096, 0.41, 0.085, 1.0)
		var stone_color := Color(0.45, 0.45, 0.45)
		data_tool.set_vertex_color(i, grass_color.lerp(color2, t))
	array_plane.clear_surfaces()
	data_tool.commit_to_surface(array_plane)
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.set_smooth_group(-1)# flat shading for the low poly look
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
	generate_bushes(_noise, _x, _z, _chunk_size)
	generate_ferns(_noise, _x, _z, _chunk_size)
	generate_grass(_noise, _x, _z, _chunk_size)
	generate_trees(_noise, _x, _z, _chunk_size)
	
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
func generate_bushes(_noise, chunk_world_x: float, chunk_world_z: float, _chunk_size: int) -> void:
	var multimesh_inst = get_node_or_null("Bushes")
	if not multimesh_inst:
		printerr("Bushes node not found!")
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
func generate_ferns(_noise, chunk_world_x: float, chunk_world_z: float, _chunk_size: int) -> void:
	var multimesh_inst = get_node_or_null("Ferns")
	if not multimesh_inst:
		printerr("Ferns node not found!")
		return
		
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = multimesh_inst.multimesh.mesh if multimesh_inst.multimesh else null
	multimesh_inst.multimesh = multimesh
	
	var instance_count = 5
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
		
		if height > (HEIGHT_MIN-40) and height < HEIGHT_CAP:
			var t = Transform3D()
			t.origin = Vector3(local_x, height, local_z)
			t = t.rotated_local(Vector3.UP, randf() * TAU)
			
			var scale_factor = 100#randf_range(20.0, 100.0)
			t = t.scaled_local(Vector3(scale_factor, scale_factor, scale_factor))
			
			multimesh.set_instance_transform(placed, t)
			placed += 1
			
	multimesh.visible_instance_count = placed
func generate_grass(_noise, chunk_world_x: float, chunk_world_z: float, _chunk_size: int) -> void:
	var multimesh_inst = get_node_or_null("Grass")
	if not multimesh_inst:
		printerr("Grass node not found!")
		return
		
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = multimesh_inst.multimesh.mesh if multimesh_inst.multimesh else null
	multimesh_inst.multimesh = multimesh
	#IDEAL COUNT IS 4000 AND SCALE 2.5
	var instance_count = 300
	multimesh.instance_count = instance_count
	multimesh.custom_aabb = AABB(Vector3(-_chunk_size, -50.0, -_chunk_size), Vector3(_chunk_size * 2.0, 100.0, _chunk_size * 2.0))
	
	var half_size = _chunk_size * 0.5
	var placed = 0
	var attempts = 0
	
	while placed < instance_count and attempts < instance_count * 3:
		attempts += 1
		var local_x = randf_range(-half_size, half_size)
		var local_z = randf_range(-half_size, half_size)
		
		var height = _noise.get_noise_2d(local_x + chunk_world_x, local_z + chunk_world_z) * 35.0
		
		if height > (HEIGHT_MIN-40) and height < HEIGHT_CAP:
			var t = Transform3D()
			t.origin = Vector3(local_x, height, local_z)
			t = t.rotated_local(Vector3.UP, randf() * TAU)
			
			var scale_factor = 20.0#randf_range(20.0, 100.0)#
			t = t.scaled_local(Vector3(scale_factor, 3.5, scale_factor))
			
			multimesh.set_instance_transform(placed, t)
			placed += 1
			
	multimesh.visible_instance_count = placed
func generate_trees(_noise, chunk_world_x: float, chunk_world_z: float, _chunk_size: int) -> void:
	var multimesh_inst = get_node_or_null("Trees")
	if not multimesh_inst:
		printerr("Trees node not found!")
		return
		
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = multimesh_inst.multimesh.mesh if multimesh_inst.multimesh else null
	multimesh_inst.multimesh = multimesh
	var instance_count = 1
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
			
			var scale_factor = 3.0#randf_range(20.0, 100.0)
			t = t.scaled_local(Vector3(scale_factor, scale_factor, scale_factor))
			
			multimesh.set_instance_transform(placed, t)
			placed += 1
			
	multimesh.visible_instance_count = placed
	var tree_shape = CapsuleShape3D.new()#multimesh.mesh.create_convex_shape() 
	for i in range(placed):
		var static_body = StaticBody3D.new()
		var collision_shape = CollisionShape3D.new()
		
		collision_shape.shape = tree_shape
		static_body.transform = multimesh.get_instance_transform(i)
		
		static_body.add_child(collision_shape)
		multimesh_inst.add_child(static_body)

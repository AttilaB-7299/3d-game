extends Node3D
class_name Chunk

var mesh_instance: MeshInstance3D
var noise: FastNoiseLite
var x: int
var z: int
var chunk_size: int
var should_remove := true

func _init(_noise: FastNoiseLite, _x: int, _z: int, _chunk_size: int) -> void:
	noise = _noise
	x = _x
	z = _z
	chunk_size = _chunk_size
	generate_chunk()

func generate_chunk() -> void:
	var subdivisions := int(chunk_size * 0.5)
	var verts_per_side := subdivisions + 2
	
	# 1. Build the visual mesh
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = subdivisions
	plane_mesh.subdivide_width = subdivisions
	
	var surface_tool := SurfaceTool.new()
	var data_tool := MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane := surface_tool.commit()
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex := data_tool.get_vertex(i)
		vertex.y = noise.get_noise_2d(vertex.x + x, vertex.z + z) * 80.0
		data_tool.set_vertex(i, vertex)
		
	array_plane.clear_surfaces()
	data_tool.commit_to_surface(array_plane)
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
	
	var map_data := PackedFloat32Array()
	map_data.resize(verts_per_side * verts_per_side)
	
	var half_size := chunk_size * 0.5
	var step := float(chunk_size) / float(verts_per_side - 1)
	
	var idx := 0
	for row in range(verts_per_side):
		var local_z := -half_size + (row * step)
		for col in range(verts_per_side):
			var local_x := -half_size + (col * step)
			map_data[idx] = noise.get_noise_2d(local_x + x, local_z + z) * 80.0
			idx += 1
			
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

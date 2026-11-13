extends Node3D
class_name Chunk

var mesh_instance: MeshInstance3D
var should_remove := true

func _init(_noise: FastNoiseLite, _x: int, _z: int, _chunk_size: int, map_data: PackedFloat32Array, verts_per_side: int, step: float) -> void:
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
		
		var t = inverse_lerp(2.0, 22.0, height)
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

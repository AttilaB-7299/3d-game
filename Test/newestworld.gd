extends Node3D

const CHUNK_SIZE = 32
const CHUNK_AMOUNT = 16
var last_chunk_pos := Vector2i(999999, 999999) 

var noise: FastNoiseLite
var chunks = {}
var unready_chunks = {}
var should_remove = true

func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3 # Height layers
	noise.frequency = 0.005 # Hills and valleys

func add_chunk(x: int, z: int):
	var key = "%d,%d" % [x, z]
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	unready_chunks[key] = true
	WorkerThreadPool.add_task(generate_chunk_data.bind(x, z, key))

func generate_chunk_data(x: int, z: int, key: String):
	# 1. Pure data calculation (Safe on worker thread)
	var subdivisions := int(CHUNK_SIZE * 0.5)
	var verts_per_side := subdivisions + 2
	var map_data := PackedFloat32Array()
	map_data.resize(verts_per_side * verts_per_side)
	
	var half_size := CHUNK_SIZE * 0.5
	var step := float(CHUNK_SIZE) / float(verts_per_side - 1)
	
	var idx := 0
	var world_x_origin = x * CHUNK_SIZE
	var world_z_origin = z * CHUNK_SIZE
	
	for row in range(verts_per_side):
		var local_z := -half_size + (row * step)
		for col in range(verts_per_side):
			var local_x := -half_size + (col * step)
			map_data[idx] = noise.get_noise_2d(local_x + world_x_origin, local_z + world_z_origin) * 35.0
			idx += 1
			
	call_deferred("spawn_chunk", x, z, key, map_data, verts_per_side, step)

func spawn_chunk(x: int, z: int, key: String, map_data: PackedFloat32Array, verts_per_side: int, step: float):
	var chunk = Chunk.new(noise, x * CHUNK_SIZE, z * CHUNK_SIZE, CHUNK_SIZE, map_data, verts_per_side, step)
	chunk.position = Vector3(x * CHUNK_SIZE, 0, z * CHUNK_SIZE)
	add_child(chunk)
	chunk.should_remove = false
	chunks[key] = chunk
	unready_chunks.erase(key)

func _process(_delta: float) -> void:
	var player_pos = $Player.position
	var current_chunk_pos = Vector2i(
		floori(player_pos.x / CHUNK_SIZE),
		floori(player_pos.z / CHUNK_SIZE)
	)
	
	if current_chunk_pos != last_chunk_pos:
		last_chunk_pos = current_chunk_pos
		update_chunks(current_chunk_pos.x, current_chunk_pos.y)
		clean_up_chunks()
		reset_chunks()

func update_chunks(p_x, p_z):
	var half_amount = int(CHUNK_AMOUNT * 0.5)
	for x in range(p_x - half_amount, p_x + half_amount):
		for z in range(p_z - half_amount, p_z + half_amount):
			add_chunk(x, z)
			var chunk = get_chunk(x, z)
			if chunk != null:
				chunk.should_remove = false
			
func clean_up_chunks():
	var keys_to_remove: Array[String] = []
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			keys_to_remove.append(key)
			
	for key in keys_to_remove:
		chunks.erase(key)

func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true

func get_chunk(x: int, z: int) -> Chunk:
	var key = "%d,%d" % [x, z]
	return chunks.get(key, null)

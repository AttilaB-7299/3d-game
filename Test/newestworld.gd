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
	noise.fractal_octaves = 2 #height 
	noise.frequency = 0.002 #hills and valleys

func add_chunk(x: int, z: int):
	var key = "%d,%d" % [x, z]
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	unready_chunks[key] = true
	# WorkerThreadPool runs tasks across multiple CPU cores automatically
	WorkerThreadPool.add_task(load_chunk.bind(x, z, key))

func load_chunk(x: int, z: int, key: String):
	var chunk = Chunk.new(noise, x * CHUNK_SIZE, z * CHUNK_SIZE, CHUNK_SIZE)
	chunk.position = Vector3(x * CHUNK_SIZE, 0, z * CHUNK_SIZE)
	
	call_deferred("load_done", chunk, key)

func load_done(chunk: Node3D, key: String):
	add_child(chunk)
	chunk.should_remove = false
	chunks[key] = chunk
	unready_chunks.erase(key)


#func _process(_delta: float) -> void:
	#update_chunks()
	#clean_up_chunks()
	#reset_chunks()
#var last_chunk_pos := Vector2i(999999, 999999)

func _process(_delta: float) -> void:
	var player_pos = $Player.position
	var current_chunk_pos = Vector2i(
		floori(player_pos.x / CHUNK_SIZE),
		floori(player_pos.z / CHUNK_SIZE)
	)
	
	# Only recalculate chunks when the player enters a new chunk
	if current_chunk_pos != last_chunk_pos:
		last_chunk_pos = current_chunk_pos
		update_chunks(current_chunk_pos.x, current_chunk_pos.y)
		clean_up_chunks()
		reset_chunks()

func update_chunks(p_x, p_z):
	var player_pos = $Player.position
	# floori prevents duplicate chunks when crossing 0 into negative coordinates
	#var p_x = floori(player_pos.x / CHUNK_SIZE)
	#var p_z = floori(player_pos.z / CHUNK_SIZE)
	
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
		
	pass
func get_chunk(x: int, z: int) -> Chunk:
	var key = "%d,%d" % [x, z]
	return chunks.get(key, null)

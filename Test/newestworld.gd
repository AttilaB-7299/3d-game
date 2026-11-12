extends Node3D

const CHUNK_SIZE = 16
const CHUNK_AMOUNT = 16

var noise: FastNoiseLite
var chunks = {}
var unready_chunks = {}

func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 4
	noise.frequency = 0.002 # Much lower for smooth hills and valleys

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
	chunks[key] = chunk
	unready_chunks.erase(key)

func _process(_delta: float) -> void:
	update_chunks()

func update_chunks():
	var player_pos = $TESTPlayer.position
	# floori prevents duplicate chunks when crossing 0 into negative coordinates
	var p_x = floori(player_pos.x / CHUNK_SIZE)
	var p_z = floori(player_pos.z / CHUNK_SIZE)
	
	var half_amount = int(CHUNK_AMOUNT * 0.5)
	for x in range(p_x - half_amount, p_x + half_amount):
		for z in range(p_z - half_amount, p_z + half_amount):
			add_chunk(x, z)

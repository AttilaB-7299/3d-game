extends Camera3D

var default = 75
var running = 90
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fov = default
	pass # Replace with function body.
@onready var player: Player = $"../../.."
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (player.running):
		fov = running
	elif (!player.running):
		fov = default
	pass

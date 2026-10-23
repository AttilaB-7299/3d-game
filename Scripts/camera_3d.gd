extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@onready var player: Player = $"../../.."
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (player.running):
		fov = 100
	elif (!player.running):
		fov = 75
	pass

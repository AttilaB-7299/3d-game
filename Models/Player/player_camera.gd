extends Node3D

@export var player: Player

@onready var camera := %Camera3D

@export_group("fov")
@export var default := 75.0
@export var running := 90.0
@export var fov_change_speed := 1


func _ready() -> void:
	camera.fov = default

func _process(_delta: float) -> void:
	if (player.state_machine.current_state.state_name == "run"):
		camera.fov = lerp(camera.fov, running, _delta * fov_change_speed)
	# if (player.running):
	# 	camera.fov = lerp(camera.fov, running, _delta * fov_change_speed)
	else:
		camera.fov = lerp(camera.fov, default, _delta * fov_change_speed)

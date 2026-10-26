
extends Node3D
@export var health_overlay_scene: PackedScene 

func _ready() -> void:
	pass
	#if health_overlay_scene:
		#var overlay_instance = health_overlay_scene.instantiate()
		#add_child(overlay_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

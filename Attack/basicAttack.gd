extends Node3D
class_name Attack
var damage : float
var size : float
var element : String
var form : String
var projectileRange : float
var isAOE : bool
var direction : Vector3
var camera_basis : Basis
var speed : float
var thrown : bool
var current_speed := 0.0
#var player : Player
@export var velocity := 0
@export var deceleration := 5.0
var move_direction: Vector3 = Vector3.ZERO

func _init():
	if (isAOE):
		projectileRange = 0
	else:
		projectileRange = projectileRange
	if (form == "Ball"):	
		var csg = CSGSphere3D.new()
		var material = preload("res://Test/terrain.material")
		csg.material = material
		csg.radius = size
		csg.bake_collision_shape()
	else:
		var csg = CSGSphere3D.new()
		var material = preload("res://Test/terrain.material")
		csg.material = material
		#csg.radius = size +3
		#csg.bake_collision_shape()
		#csg.
		
	
func _ready() -> void:
	
	pass # Replace with function body.

func launch(dir: Vector3) -> void:
	move_direction = dir.normalized()
	current_speed = projectileRange
	thrown = true

func _sendProjectile(delta: float) -> void:
	# Move along the camera's forward direction
	var basis = move_direction
	global_position += basis * current_speed * delta
	
	# Reduce speed over time until it reaches 0
	current_speed = move_toward(current_speed, 0.0, deceleration * delta)
	
	if current_speed <= 0.0:
		thrown = false

func _process(delta: float) -> void:
	if thrown:
		_sendProjectile(delta)

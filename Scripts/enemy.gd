extends CharacterBody3D
@onready var killzone: Area3D = $Killzone

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(_delta: float) -> void:

	move_and_slide()

extends State

@export var move_speed := 10.0
@onready var blockbench_export: Node3D = $"../../blockbench_export"

func _state_physics_process(_delta: float) -> void:
	blockbench_export._animBlend("run", 0.2)

	parent._handle_horazontal_movement(move_speed)

	handle_possible_state_change()

func _exit() -> void:
	pass


func handle_possible_state_change():
	if !Input.get_vector("move left", "move right", "move forward", "move back"):
		state_machine.change_state("idle")

	if !parent.is_on_floor():
		state_machine.change_state("jump")
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")

	if Input.is_action_just_released("sprint"):
		state_machine.change_state("walk")

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state("attack")

	if Input.is_action_pressed("open inventory"):
		state_machine.change_state("inventory")


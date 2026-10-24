extends State


@onready var blockbench_export: Node3D = $"../../blockbench_export"
@export var move_speed := 8.75

func _enter() -> void:
	# ual_2_standard._animBlend("run", 0.2)
	print_debug("RUN STATE ENTERED")

func _state_physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state("attack")
	blockbench_export._animBlend("run", 0.2)

	parent._handle_horazontal_movement(move_speed)

	handle_possible_state_change()

func _exit() -> void:
	print_debug("RUN STATE EXITED")


func handle_possible_state_change():
	if !Input.get_vector("move left", "move right", "move forward", "move back"):
		state_machine.change_state("idle")

	if !parent.is_on_floor():
		state_machine.change_state("fall")
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")

	if Input.is_action_just_released("sprint"):
		state_machine.change_state("walk")

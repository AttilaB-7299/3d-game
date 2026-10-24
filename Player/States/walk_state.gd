extends State

@onready var blockbench_export: Node3D = $"../../blockbench_export"
@export var move_speed := 5.0

func _enter() -> void:
	# ual_2_standard._animBlend("walk", 0.2)
	print_debug("WALK STATE ENTERED")

func _state_physics_process(_delta: float) -> void:
	blockbench_export._animBlend("walk", 0.2)
	parent._handle_horazontal_movement(move_speed)

	handle_possible_state_change()

func _exit() -> void:
	print_debug("WALK STATE EXITED")

func handle_possible_state_change():
	if !Input.get_vector("move left", "move right", "move forward", "move back"):
		state_machine.change_state("idle")

	if !parent.is_on_floor():
		state_machine.change_state("jump") # because multiple jumps
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")

	if Input.is_action_pressed("sprint"):
		state_machine.change_state("run")


	if Input.is_action_pressed("attack"):
		parent.velocity = Vector3.ZERO
		state_machine.change_state("attack")

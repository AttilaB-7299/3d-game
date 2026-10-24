extends State

@export var blockbench_export: Node3D 

func _enter() -> void:
	blockbench_export._animBlend("default", 0.2)
	print_debug("IDLE STATE ENTERED")

func _state_physics_process(_delta: float) -> void:
	handle_possible_state_change()

func _exit() -> void:
	print_debug("IDLE STATE EXITED")


func handle_possible_state_change():
	if !parent.is_on_floor():
		state_machine.change_state("fall")

	if Input.get_vector("move left", "move right", "move forward", "move back"):
		if !Input.is_action_pressed("sprint"):
			state_machine.change_state("walk")
		else:
			state_machine.change_state("run")
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state("attack")



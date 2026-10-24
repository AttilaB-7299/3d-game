extends State

@export var gravity_multiplier := 1.5
@export var move_speed := 5.0

func _enter() -> void:
	print_debug("FALL STATE ENTERED")

func _state_physics_process(_delta: float) -> void:
	parent._handle_horazontal_movement(move_speed)
	parent._handle_gravity(_delta, gravity_multiplier)

	if parent.is_on_floor():
		# if Input.is_action_pressed("jump"):
		# 	state_machine.change_state("jump")
		if Input.get_vector("move left", "move right", "move forward", "move back"):
			if Input.is_action_pressed("sprint"):
				state_machine.change_state("run")
			else:
				state_machine.change_state("walk")
		state_machine.change_state("idle")

func _exit() -> void:
	print_debug("FALL STATE EXITED")


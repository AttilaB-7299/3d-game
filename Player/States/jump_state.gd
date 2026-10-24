extends State

@export var jumps := 3
@export var jump_velocity := 6.5
@export var gravity_multiplier := 1.5
@export var move_speed := 5.0

var jumps_left
var can_jump := false

func _enter() -> void:
	jumps_left = jumps
	print_debug("JUMP STATE ENTERED")
	if jumps_left && Input.is_action_pressed("jump"):
		handle_jumping()

func _state_physics_process(_delta: float) -> void:
	parent._handle_horazontal_movement(move_speed)
	parent._handle_gravity(_delta, gravity_multiplier)

	if parent.is_on_floor():
		if Input.get_vector("move left", "move right", "move forward", "move back"):
			if Input.is_action_pressed("sprint"):
				state_machine.change_state("run")
			else:
				state_machine.change_state("walk")
		state_machine.change_state("idle")


	if Input.is_action_just_released("jump"):
		can_jump = true


	if Input.is_action_just_pressed("jump") && can_jump:
		handle_jumping()

func _exit() -> void:
	print_debug("JUMP STATE EXITED")


func handle_jumping() -> void:
	parent.velocity.y = jump_velocity
	jumps_left -= 1
	if jumps_left == 0:
		state_machine.change_state("fall")

	can_jump = false

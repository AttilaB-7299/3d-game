extends State

@onready var blockbench_export: Node3D = $"../../blockbench_export"
@export var attack_box: Killzone

var attack_count: int


func _enter() -> void:
	attack_count = 1
	blockbench_export._animBlend("attack", 0.2)
	print_debug("ATTACK STATE ENTERED")

	await get_tree().create_timer(0.5).timeout
	print("ENABLE ATTACK")
	attack_box._hitboxEnable()
	if (attack_count < 3):
		attack_count += 1
	else:
		attack_count = 1
	print ("done ",  attack_count, " attacks")
	await get_tree().create_timer(0.1).timeout
	print("DISABLE ATTACK")
	attack_box._hitboxDisable()

	handle_possible_state_change()

func _exit() -> void:
	print_debug("ATTACK STATE EXITED")
func _state_physics_process(_delta: float) -> void:
	#walk and punch
	parent._handle_horazontal_movement(5.0)

func handle_possible_state_change():
	if !parent.is_on_floor():
		state_machine.change_state("fall")

	if Input.get_vector("move left", "move right", "move forward", "move back"):
		if !Input.is_action_pressed("sprint"):
			state_machine.change_state("walk")
		else:
			state_machine.change_state("run")
	state_machine.change_state("idle")

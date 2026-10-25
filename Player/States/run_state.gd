extends State


@onready var blockbench_export_2: Node3D = $"../../KnightModel/blockbench_export2"
@onready var blockbench_export_3: Node3D = $"../../KnightModel/blockbench_export3"
@onready var blockbench_export_4: Node3D = $"../../KnightModel/blockbench_export4"
@onready var blockbench_export_5: Node3D = $"../../KnightModel/blockbench_export5"
@onready var blockbench_export_6: Node3D = $"../../KnightModel/blockbench_export6"
@onready var blockbench_export_7: Node3D = $"../../KnightModel/blockbench_export7"
@export var move_speed := 10.0

func _enter() -> void:
	for i in range(2, 8):
		var node_path = "../../KnightModel/blockbench_export%s" % i
		var export_node = get_node_or_null(node_path)
		if export_node:
			export_node._animBlend("run", 0.2)

func _state_physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state("attack")
	for i in range(2, 8):
		var node_path = "../../KnightModel/blockbench_export%s" % i
		var export_node = get_node_or_null(node_path)
		if export_node:
			export_node._animBlend("run", 0.2)
	#blockbench_export._animBlend("run", 0.2)

	parent._handle_horazontal_movement(move_speed)

	handle_possible_state_change()

func _exit() -> void:
	pass
	#print_debug("RUN STATE EXITED")


func handle_possible_state_change():
	if !Input.get_vector("move left", "move right", "move forward", "move back"):
		state_machine.change_state("idle")

	if !parent.is_on_floor():
		state_machine.change_state("fall")
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")

	if Input.is_action_just_released("sprint"):
		state_machine.change_state("walk")

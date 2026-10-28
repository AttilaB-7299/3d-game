extends State

#@onready var blockbench_export_2: Node3D = $"../../KnightModel/blockbench_export2"
#@onready var blockbench_export_3: Node3D = $"../../KnightModel/blockbench_export3"
#@onready var blockbench_export_4: Node3D = $"../../KnightModel/blockbench_export4"
#@onready var blockbench_export_5: Node3D = $"../../KnightModel/blockbench_export5"
#@onready var blockbench_export_6: Node3D = $"../../KnightModel/blockbench_export6"
#@onready var blockbench_export_7: Node3D = $"../../KnightModel/blockbench_export7"
@export var move_speed := 5.0
@onready var blockbench_export: Node3D = $"../../blockbench_export"

func _enter() -> void:
	#for i in range(2, 8):
		#var node_path = "../../KnightModel/blockbench_export%s" % i
		#var export_node = get_node_or_null(node_path)
		#if export_node:
	blockbench_export._animBlend("walk", 0.2)

func _state_physics_process(_delta: float) -> void:
	#for i in range(2, 8):
		#var node_path = "../../KnightModel/blockbench_export%s" % i
		#var export_node = get_node_or_null(node_path)
		#if export_node:
	blockbench_export._animBlend("walk", 0.2)	
	parent._handle_horazontal_movement(move_speed)

	handle_possible_state_change()

func _exit() -> void:
	pass
	#print_debug("WALK STATE EXITED")

func handle_possible_state_change():
	if !Input.get_vector("move left", "move right", "move forward", "move back"):
		state_machine.change_state("idle")

	if !parent.is_on_floor():
		state_machine.change_state("jump") # because multiple jumps
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state("jump")

	if Input.is_action_pressed("sprint"):
		state_machine.change_state("run")


	if Input.is_action_just_pressed("attack"):
		parent.velocity = Vector3.ZERO
		state_machine.change_state("attack")

	if Input.is_action_pressed("open inventory"):
		state_machine.change_state("inventory")

extends State

#@onready var blockbench_export: Node3D = $"../../blockbench_export"
@onready var blockbench_export_2: Node3D = $"../../KnightModel/blockbench_export2"
@onready var blockbench_export_3: Node3D = $"../../KnightModel/blockbench_export3"
@onready var blockbench_export_4: Node3D = $"../../KnightModel/blockbench_export4"
@onready var blockbench_export_5: Node3D = $"../../KnightModel/blockbench_export5"
@onready var blockbench_export_6: Node3D = $"../../KnightModel/blockbench_export6"
@onready var blockbench_export_7: Node3D = $"../../KnightModel/blockbench_export7"

#func _enter() -> void:
	#var blockbench_export 
	#for i in range (2, 7):
		#blockbench_export = ("blockbench_export_%s" % i)
		#blockbench_export._animBlend("default", 0.2)
		#pass
	##blockbench_export._animBlend("default", 0.2)
	##print_debug("IDLE STATE ENTERED")
func _enter() -> void:
	for i in range(2, 8):
		var node_path = "../../KnightModel/blockbench_export%s" % i
		var export_node = get_node_or_null(node_path)
		if export_node:
			export_node._animBlend("default", 0.2)

func _state_physics_process(_delta: float) -> void:
	handle_possible_state_change()

func _exit() -> void:
	pass
	#print_debug("IDLE STATE EXITED")


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

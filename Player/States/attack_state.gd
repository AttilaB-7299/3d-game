extends State
#NOTE EXPORT 5 IS RIGHT ARM
@onready var blockbench_export: Node3D = $"../../blockbench_export"

#@onready var blockbench_export_2: Node3D = $"../../KnightModel/blockbench_export2"
#@onready var blockbench_export_3: Node3D = $"../../KnightModel/blockbench_export3"
#@onready var blockbench_export_4: Node3D = $"../../KnightModel/blockbench_export4"
#@onready var blockbench_export_5: Node3D = $"../../KnightModel/blockbench_export5"
#@onready var blockbench_export_6: Node3D = $"../../KnightModel/blockbench_export6"
#@onready var blockbench_export_7: Node3D = $"../../KnightModel/blockbench_export7"
@export var attack_box: Killzone

var attack_count: int

func _enter() -> void:
	attack_count = 1
	#if (state_machine.current_state == state_machine.run):
		#blockbench_export.anim_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	#else:
		#blockbench_export._animBlend("hit", 0.2)
	blockbench_export._animBlend("hit", 0.2)
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
		state_machine.change_state("jump")

	if Input.get_vector("move left", "move right", "move forward", "move back"):
		if !Input.is_action_pressed("sprint"):
			state_machine.change_state("walk")
		else:
			state_machine.change_state("run")
	state_machine.change_state("idle")

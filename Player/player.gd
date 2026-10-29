extends CharacterBody3D
class_name Player
signal took_damage

var attack_count = 0
var MAX_HEALTH = 5
@onready var blockbench_export: Node3D = $blockbench_export
@onready var dev_controls: Node = $DevControls

#@onready var blockbench_export_2: Node3D = $"KnightModel/blockbench_export2"
#@onready var blockbench_export_3: Node3D = $"KnightModel/blockbench_export3"
#@onready var blockbench_export_4: Node3D = $"KnightModel/blockbench_export4"
#@onready var blockbench_export_5: Node3D = $"KnightModel/blockbench_export5"
#@onready var blockbench_export_6: Node3D = $"KnightModel/blockbench_export6"
#@onready var blockbench_export_7: Node3D = $"KnightModel/blockbench_export7"

@onready var pivot: Node3D = $PlayerCamera
@onready var attack_box: Area3D = $attackBox
@export var health = MAX_HEALTH
@export var sens = 0.5
@onready var state_machine: StateMachine = $StateMachine
@onready var hotbar = $HotBar
@onready var health_bar = $HealthBar

const pause_menu = preload("res://UI/Menu/pause_menu.tscn")
func checkPickUp():
	pass
	#if 
func changeMaxHealth(change: int):
	MAX_HEALTH += change

func maxHealth():
	return MAX_HEALTH

func getHealth():
	return health

func damage(_damage):
	health -= _damage
	took_damage.emit()

func setHealth(newHealth: int):
	health = newHealth

func attackAmount():
	return attack_count

var mouseSensitivity := 0.1
var rotation_x := 0.0
var rotation_y := 0.0

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var attack = attack_box as Killzone
	attack._setOwner("Player")
	attack._hitboxDisable() 

func _input(event):
	if state_machine.current_state.state_name == "inventory":
		return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(_delta: float) -> void:	
	if not is_inside_tree():
		return

	if Input.is_action_just_pressed("pause game"):
		get_tree().current_scene.add_child(pause_menu.instantiate())
		get_tree().paused = true
	dev_controls._physics_process(_delta)
	move_and_slide()


# This function should be called in a State
func _handle_horazontal_movement(move_speed: float):
	var input_dir := Input.get_vector("move left", "move right", "move forward", "move back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

# This function should be called in a State
func _handle_gravity(delta: float, grav_mult):
	velocity += get_gravity() * delta * grav_mult
	pass

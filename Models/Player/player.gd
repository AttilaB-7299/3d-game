extends CharacterBody3D
class_name Player
const MAX_HEALTH = 5
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var moving = false
var hitting = false
@onready var pivot: Node3D = $cameraOrigin
@onready var blockbench_export: Node3D = $blockbench_export
@onready var attack_box: Area3D = $attackBox

@export var health := MAX_HEALTH
@export var sens = 0.5

func getHealth():
	return health
func setHealth(newHealth: int):
	health = newHealth

var jumps := 0
var sprintSpeed := 1.0
var mouseSensitivity := 0.1
var rotation_x := 0.0
var rotation_y := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var attack = attack_box as Killzone
	attack._hitboxDisable() 
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	if event is InputEventMouseButton:
		attack()
		#var attack = attack_box as Killzone 
		#if Input.is_action_just_pressed("attack"):
			#blockbench_export._playAnim("hit")
			#print("ENABLE ATTACK")
			#attack._hitboxEnable()
		#if Input.is_action_just_released("attack"):
			#print("DISABLE ATTACK")
			#attack._hitboxDisable()
func _physics_process(delta: float) -> void:	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#if Input.is_action_just_pressed("attack"):
		#hit_timer.start()
	#if Input.is_action_just_released("attack") && hit_timer.time_left == 0:
		#var attack = attack_box as Killzone 
		#print("DISABLE ATTACK")
		#attack._hitboxDisable()
		#
	# Handle Sprint
	if Input.is_action_pressed("sprint") and is_on_floor():
		sprintSpeed = 1.75
	if Input.is_action_just_released("sprint"):
		sprintSpeed = 1

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || jumps < 3):
		jumps += 1
		if is_on_floor():
			jumps = 0
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move left", "move right", "move forward", "move back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		moving = true
		if (!hitting):
			blockbench_export._playAnim("walk")
		velocity.x = direction.x * SPEED * sprintSpeed
		velocity.z = direction.z * SPEED * sprintSpeed
	else:
		moving = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
func attack():
	hitting = true
	var attack = attack_box as Killzone 
	blockbench_export._playAnim("hit")
	#should be the duration of anim
	await get_tree().create_timer(0.5).timeout
	print("ENABLE ATTACK")
	attack._hitboxEnable()
	await get_tree().create_timer(0.1).timeout
	print("DISABLE ATTACK")
	attack._hitboxDisable()
	hitting = false
	await get_tree().create_timer(0.05).timeout
	if (!moving):
		blockbench_export._playAnim("default")
	
	#hit_timer.start()
	#waits animation time
	#await get_tree().create_timer(1.0).timeout
	#print("ENABLE ATTACK")
	#attack._hitboxEnable()
#func disableAttack():
	#var attack = attack_box as Killzone 
	#print("DISABLE ATTACK")
	#attack._hitboxDisable()

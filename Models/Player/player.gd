extends CharacterBody3D
class_name Player
signal took_damage
const SPEED = 5.0
const JUMP_VELOCITY = 5.5
const GRAV_MULTIPLIER = 1.5
var moving = false
var hitting = false
var attack_count = 0
var running = false
var MAX_HEALTH = 5
@onready var pivot: Node3D = $cameraOrigin
@onready var blockbench_export: Node3D = $blockbench_export
@onready var attack_box: Area3D = $attackBox
@export var health = MAX_HEALTH
@export var sens = 0.5

func changeMaxHealth(change: int):
	MAX_HEALTH += change
func maxHealth():
	return MAX_HEALTH
func getHealth():
	return health
func damage(damage: int):
	health -= damage
	took_damage.emit()
func setHealth(newHealth: int):
	health = newHealth
func attackAmount():
	return attack_count
var jumps := 0
var sprintSpeed := 1.0
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
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
func _physics_process(delta: float) -> void:	
	if not is_inside_tree():
		return
	gravity(delta)
	handleAttack()
	handleMovement()
	handleJump()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	# Get the input direction and handle the movement/deceleration.
	#var input_dir := Input.get_vector("move left", "move right", "move forward", "move back")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#moving = true
		#if (!hitting && !running):
			#blockbench_export._playAnim("walk")
		#velocity.x = direction.x * SPEED * sprintSpeed
		#velocity.z = direction.z * SPEED * sprintSpeed
	#else:
		#moving = false
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func gravity(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAV_MULTIPLIER
func handleAttack():
	if Input.is_action_just_pressed("attack"):
		if hitting:
			return
		hitting = true
		var attack = attack_box as Killzone 
		blockbench_export._playAnim("attack")
		#should be the duration of anim
		await get_tree().create_timer(0.5).timeout
		print("ENABLE ATTACK")
		attack._hitboxEnable()
		if (attack_count < 3):
			attack_count += 1
		else:
			attack_count = 0
			attack_count += 1
		print ("done ",  attack_count, " attacks")
		await get_tree().create_timer(0.1).timeout
		print("DISABLE ATTACK")
		attack._hitboxDisable()
		hitting = false
		await get_tree().create_timer(0.05).timeout
		fixAnim()
func fixAnim():
	if hitting:
		pass
	elif moving:
		#change this
		pass
	elif (!moving and !hitting):
		blockbench_export._playAnim("default")
func handleJump():
	if Input.is_action_just_pressed("jump") and (is_on_floor() || jumps < 3):
		jumps += 1
		if is_on_floor():
			jumps = 0
		velocity.y = JUMP_VELOCITY
func handleMovement():
	var input_dir := Input.get_vector("move left", "move right", "move forward", "move back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if (!input_dir && (running || direction)):
		blockbench_export._stopAnim()
	if direction:
		moving = true
		if (!hitting && !running):
			blockbench_export._playAnim("walk")
		elif (running):
			blockbench_export._playAnim("run")
		velocity.x = direction.x * SPEED * sprintSpeed
		velocity.z = direction.z * SPEED * sprintSpeed
	else:
		moving = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_pressed("sprint") and is_on_floor():
		running = true
		sprintSpeed = 1.75
	if Input.is_action_just_released("sprint"):
		running = false
		if (moving):
			blockbench_export._playAnim("walk")
		else:
			blockbench_export._playAnim("default")
		sprintSpeed = 1

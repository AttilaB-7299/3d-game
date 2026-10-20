extends CharacterBody3D

@onready var pivot: Node3D = $cameraOrigin
@onready var anim_player = $AnimationPlayer

const ANIMATION_RES = preload("uid://cakes75qtkxtt") as Animation

@export var sens = 0.5
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var jumps := 0
var sprintSpeed := 1.0
var mouseSensitivity := 0.1
var rotation_x := 0.0
var rotation_y := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 

	var anim_library = anim_player.get_animation_library("")
	if not anim_library:
		anim_library = AnimationLibrary.new()
		anim_player.add_animation_library("", anim_library)
		
	if ANIMATION_RES:
		anim_library.add_animation("my_new_animation", ANIMATION_RES)	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta: float) -> void:	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle Sprint
	if Input.is_action_pressed("sprint") and is_on_floor():
		sprintSpeed = 1.75
		# Play your animation here when sprinting if desired:
		# if not anim_player.is_playing() or anim_player.current_animation != "my_new_animation":
		# 	anim_player.play("my_new_animation")
	if Input.is_action_just_released("sprint"):
		sprintSpeed = 1
		# anim_player.stop()

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
		anim_player.play("walk")
		velocity.x = direction.x * SPEED * sprintSpeed
		velocity.z = direction.z * SPEED * sprintSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

extends CharacterBody3D
class_name Player

# signal took_damage
signal pickup_item(item: Item)
signal pickup_item_hotbar(index: int)
signal pickup_item_hidden(index: int)

@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitBoxComponent = $HitBoxComponent
@onready var attackbox_component: AttackBoxComponent = $AttackBoxComponent

@onready var state_machine: StateMachine = $StateMachine

@onready var blockbench_export: Node3D = $blockbench_export
@onready var dev_controls: Node = $DevControls


@onready var pivot: Node3D = $PlayerCamera
@export var sens = 0.5
@onready var hotbar = $HotBar
@onready var health_bar = $HealthBar

@onready var hiddenInv: Inventory = $HiddenInv
@onready var hotbarInv: Inventory = $HotbarInv

const pause_menu = preload("res://UI/Menu/pause_menu.tscn")

var mouseSensitivity := 0.1
var rotation_x := 0.0
var rotation_y := 0.0

func _ready() -> void:
	attackbox_component.enabled = false
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
		# close inventory
		if state_machine.current_state.state_name == "inventory":
			state_machine.change_state("idle")

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


# adds item to inventory if there is space
func attempt_pickup_item(item: Item) -> bool: # TODO: make items stackable
	for i in range(hotbarInv.vals.size()):
		if !hotbarInv.vals.get(i):
			hotbarInv.vals.set(i, item)
			pickup_item.emit(item)
			pickup_item_hotbar.emit(i)
			return true
	
	for i in range(hiddenInv.vals.size()):
		if !hiddenInv.vals.get(i):
			hiddenInv.vals.set(i, item)
			pickup_item.emit(item)
			pickup_item_hidden.emit(i)
			return true
	
	return false
	

func _on_health_component_die():
	get_tree().call_deferred("reload_current_scene")



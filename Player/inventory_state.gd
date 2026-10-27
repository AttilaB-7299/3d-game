extends State


var inventory_scene = preload("res://UI/Menu/inventory.tscn")
var can_close_inventory := false

var inventory_node


func _enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	inventory_node = inventory_scene.instantiate()
	parent.hotbar.visible = false
	parent.health_bar.visible = false
	get_tree().current_scene.add_child(inventory_node)

func _state_physics_process(_delta: float) -> void:
	if Input.is_action_just_released("open inventory"):
		can_close_inventory = true
	if Input.is_action_just_pressed("open inventory") && can_close_inventory:
		state_machine.change_state("idle")

func _exit() -> void:
	inventory_node.queue_free()
	parent.hotbar.visible = true
	parent.health_bar.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.action_release("open inventory") # so it does not immediately open inventory again



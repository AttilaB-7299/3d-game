class_name StateMachine extends Node

@export var parent: Node
@export var initial_state: State

var current_state: State
var previous_state: State

func _ready() -> void:
	_setup_states()
	current_state = initial_state
	previous_state = initial_state

	current_state._enter()

func _physics_process(d: float) -> void:
	current_state._state_physics_process(d)

func change_state(state_name: String) -> void:
	for child: State in get_children():
		if child.state_name == state_name:
			current_state._exit()
			previous_state = current_state
			current_state = child
			current_state._enter()
			return
	push_error("State '" + state_name + "' not found")
	print("CURRENT STATE '" + state_name)

func _setup_states() -> void:
	for child: State in get_children():
		child.parent = parent
		child.state_machine = self

class_name State extends Node

@export var state_name: String

var parent
var state_machine: StateMachine

func _enter() -> void:
	pass

func _state_physics_process(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

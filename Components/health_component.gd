class_name HealthComponent extends Node

signal current_health_changed(by: int)
signal max_health_changed(by: int)
signal die

@export var max_health := 5 : set = set_max_health
@onready var current_health := max_health : set = set_current_health

func set_current_health(to: int):
	var diff := to - current_health
	to = clamp(to, 0, max_health)

	current_health = to
	if sign(diff) == -1:
		if current_health == 0:
			die.emit()
		current_health_changed.emit(diff)
		# else:

func set_max_health(to: int):
	if to != max_health:
		var diff := to - max_health
		max_health = max(to, 1)
		max_health_changed.emit(diff)

		if current_health > max_health:
			current_health = max_health



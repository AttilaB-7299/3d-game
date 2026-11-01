class_name Inventory extends Node

@export var size: int:
	set(new_val):
		if new_val < 0:
			new_val = 0
		size = new_val

var vals: Array[Item]

func _ready() -> void:
	for i in range(size):
		vals.append(null)

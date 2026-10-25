@tool
extends Control

@export var num_of_slots := 9 : set = update_num_of_slots
var selected_slot = 0 : set = update_selected_slot


@onready var slots: HBoxContainer = %Slots

func _ready() -> void:
	for i in range(num_of_slots):
		var panel: Panel = Panel.new()
		panel.custom_minimum_size = Vector2(40, 40)
		slots.add_child(panel)
	
	# slots.get_child(selected_slot).get_theme_stylebox("panel").border_width_left = 2
	# slots.get_child(selected_slot).get_theme_stylebox("panel").border_width_bottom = 2
	# slots.get_child(selected_slot).get_theme_stylebox("panel").border_width_right = 2
	# slots.get_child(selected_slot).get_theme_stylebox("panel").border_width_top = 2

func _process(delta: float) -> void:
	pass


func update_num_of_slots(new_val: int):
	if new_val < 0:
		new_val = 0

	if new_val > num_of_slots:
		var panel: Panel = Panel.new()
		panel.custom_minimum_size = Vector2(40, 40)
		slots.add_child(panel)

	else:
		var children = slots.get_children()
		children.reverse()
		for i in range(num_of_slots - new_val):
			children[i].queue_free()

	num_of_slots = new_val



func update_selected_slot(new_val: int):
	# slots.get_child(selected_slot).set_theme_override("border_width_bottom", 0)
	# slots.get_child(selected_slot).set_theme_override("border_width_left", 0)
	# slots.get_child(selected_slot).set_theme_override("border_width_top", 0)
	# slots.get_child(selected_slot).set_theme_override("border_width_right", 0)
	#
	# slots.get_child(new_val).set_theme_override("border_width_bottom", 2)
	# slots.get_child(new_val).set_theme_override("border_width_left", 2)
	# slots.get_child(new_val).set_theme_override("border_width_top", 2)
	# slots.get_child(new_val).set_theme_override("border_width_right", 2)

	selected_slot = new_val

	# if slots.get_child(i).has_theme_override():

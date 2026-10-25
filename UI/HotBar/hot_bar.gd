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
	
	var the_panel: Panel = slots.get_child(selected_slot)
	var sbf: StyleBoxFlat = StyleBoxFlat.new()
	sbf.bg_color = Color(0,0,0,.5)
	sbf.border_color = Color.BLUE
	sbf.border_width_left = 2
	sbf.border_width_right = 2
	sbf.border_width_top = 2
	sbf.border_width_bottom = 2
	the_panel.add_theme_stylebox_override("panel", sbf)

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		if Input.is_action_just_pressed("next item slot"):
			selected_slot += 1
		if Input.is_action_just_pressed("previous item slot"):
			selected_slot -= 1


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
	if new_val > num_of_slots - 1:
		new_val = 0
	elif new_val < 0:
		new_val = num_of_slots - 1
	slots.get_child(selected_slot).remove_theme_stylebox_override("panel")

	var the_panel: Panel = slots.get_child(new_val)

	var sbf: StyleBoxFlat = StyleBoxFlat.new()
	sbf.bg_color = Color(0,0,0,.5)
	sbf.border_color = Color.BLUE
	sbf.border_width_left = 2
	sbf.border_width_right = 2
	sbf.border_width_top = 2
	sbf.border_width_bottom = 2
	the_panel.add_theme_stylebox_override("panel", sbf)

	selected_slot = new_val

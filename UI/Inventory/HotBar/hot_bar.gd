@tool
extends Control


@export var player: Player

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

	if !Engine.is_editor_hint(): # I was getting an error
		# player.pickup_item_hotbar.connect(_update_slot_icon)
		if !player.is_node_ready():
			await player.ready
			player.hotbarInv.item_updated.connect(_update_slot)
		else:
			player.hotbarInv.item_updated.connect(_update_slot)


func _process(_delta: float) -> void:
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


func _update_slot(val: Item, ammount: int, index: int):
	var panel: Panel = slots.get_child(index)

	if !val:
		if panel.get_child_count(false):
			for child in panel.get_children():
				child.queue_free()
			return

	if !panel.get_child_count(false):
		var texture_rect := TextureRect.new()
		texture_rect.texture = val.icon
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.size = panel.size - Vector2.ONE * 8
		texture_rect.position = (panel.size - texture_rect.size) / 2

		var label := Label.new()
		label.position = panel.size * 0.5 + Vector2(8, -2)
		if ammount > 1:
			label.text = str(ammount)


		panel.add_child(texture_rect)
		panel.add_child(label)
	
	else:
		for child in panel.get_children():
			if child is TextureRect:
				if val.icon != child.texture:
					child.texture = val.icon

			elif child is Label:
				if ammount > 1 && int(child.text) != ammount:
					child.text = str(ammount)
				elif ammount == 1 && child.text.length():
					child.text = ""
				# if int(child.text) != ammount:
				# 	child.text = str(ammount)

		# if panel.get_child(0).texture != val.icon:
		# 	panel.get_child(0).texture = val.icon

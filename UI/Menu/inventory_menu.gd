extends CanvasLayer

@onready var hidden_items: Control = %HiddenItems
@onready var hotbar_items: Control = %HotbarItems

@export var inv_colls := 7 # TODO: fix bugs with this eventually

var can_close_inventory_keybind := false

var player_hidden_inv: Inventory
var player_hotbar_inv: Inventory

func _ready() -> void:
	var player: Player
	if !Engine.is_editor_hint():
		for i in get_tree().current_scene.get_children():
			if i is Player:
				player = i
				break
		player_hidden_inv = player.hiddenInv
		player_hotbar_inv = player.hotbarInv

	add_hidden_items()
	add_hotbar_items()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func add_hidden_items():
	for y in range(player_hidden_inv.size / inv_colls):
		for x in range(inv_colls):
			var panel := Panel.new()

			panel.size = Vector2(60, 60)

			var start_pos_x = (panel.size.x + 20) * inv_colls / 3
			var start_pos_y = (panel.size.y + 20) * (player_hidden_inv.size / inv_colls) / 4

			panel.position = Vector2(20, 20) + (panel.size + Vector2(20, 20)) * Vector2(x, y) + Vector2(start_pos_x, start_pos_y)
			hidden_items.add_child(panel)


			var area := Area2D.new()
			var coll_shape := CollisionShape2D.new()
			coll_shape.shape = RectangleShape2D.new()
			coll_shape.shape.size = panel.size
			coll_shape.position = panel.size / 2

			panel.mouse_filter = Control.MOUSE_FILTER_PASS

			add_signals_to_item(area, panel)

			panel.add_child(area)
			area.add_child(coll_shape)

func add_hotbar_items():
	for i in range(player_hotbar_inv.size):
		var panel := Panel.new()
		panel.size = Vector2(60, 60)

		var start_pos_x = (hotbar_items.size.x / 2) - ((panel.size.x + 20) * player_hotbar_inv.size - 20) / 2
		var start_pos_y = 0
		
		panel.position = Vector2(20 + 460, 20) + (panel.size + Vector2(20, 20)) * Vector2(i, 0) + Vector2(start_pos_x, start_pos_y)

		hotbar_items.add_child(panel)

		var area := Area2D.new()
		var coll_shape := CollisionShape2D.new()
		coll_shape.shape = RectangleShape2D.new()
		coll_shape.shape.size = panel.size
		coll_shape.position = panel.size / 2

		panel.mouse_filter = Control.MOUSE_FILTER_PASS

		add_signals_to_item(area, panel)

		panel.add_child(area)
		area.add_child(coll_shape)

func add_signals_to_item(area: Area2D, panel: Panel):
	area.mouse_entered.connect(func():
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(.2, .2, .2, .6)
		sb.border_color = Color(.4, .4, .4, .6)
		sb.border_width_left = 2
		sb.border_width_top = 2
		sb.border_width_right = 2
		sb.border_width_bottom = 2

		panel.add_theme_stylebox_override("panel", sb)
	)

	area.mouse_exited.connect(func():
		panel.remove_theme_stylebox_override("panel")
	)


@tool
extends CanvasLayer

@onready var inventory_items: Control = %InventoryItems
@onready var hotbar_items: Control = %HotbarItems

@export var inv_rows: int
@export var inv_colls: int

var can_close_inventory_keybind := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	if Input.is_action_just_released("open inventory"):
		can_close_inventory_keybind = true
	
	if Input.is_action_just_pressed("open inventory") && can_close_inventory_keybind:
		print_debug("close inventory")
		close_inventory()


func close_inventory():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# get_tree().call_deferred()
	call_deferred("queue_free")
	# queue_free()


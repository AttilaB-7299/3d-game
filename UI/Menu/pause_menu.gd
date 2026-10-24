extends CanvasLayer

var can_unpause_keybind := false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta: float) -> void:
	if Input.is_action_just_released("pause game"):
		can_unpause_keybind = true
	if Input.is_action_just_pressed("pause game") && can_unpause_keybind:
		unpause_game()

func _on_continue_button_pressed():
	unpause_game()

func _on_settings_button_pressed():
	pass

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/Menu/main_menu.tscn")


func unpause_game():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

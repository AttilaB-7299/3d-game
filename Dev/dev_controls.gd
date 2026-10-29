extends CharacterBody3D

func _ready() -> void:
	pass

func _input(event):
	pass

func _physics_process(_delta: float) -> void:	
	if not is_inside_tree():
		return

	if Input.is_action_just_pressed("reload scene"):
		get_tree().reload_current_scene()
	#if Input.is_action_just_pressed("summ")

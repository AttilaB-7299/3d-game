class_name Item extends Area3D
signal inRange
var obtainable := false;
func _hitboxDisable():
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)  
func _hitboxEnable():
	set_deferred("monitoring", true)  
	set_deferred("monitorable", true)  
	
func _physics_process(_delta: float) -> void:
	pass
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		print("ITEM COLLECTED")
		obtainable = true
		await get_tree().create_timer(0.2).timeout
		_hitboxDisable()
		inRange.emit()
	else:
		return

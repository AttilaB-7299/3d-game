extends Area3D

@onready var timer: Timer = $Timer
func _on_body_shape_entered(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	timer.start()
func _on_timer_timeout() -> void:
	#Engine.time_scale = 1.0
	get_tree().reload_current_scene()

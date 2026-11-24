extends Attack
@onready var timer: Timer = $Timer

func _ready() -> void:
	damage = 3.0
	size = 3.0
	element = "Fire"
	form = "Ball"
	projectileRange = 15
	isAOE = false
	timer.autostart = true
	speed = 600
	await timer.ready
	timer.start()
	pass 
#func instantiate():
	#_init()
func time_left():
	return timer.time_left
func _on_timer_timeout() -> void:
	#call_deferred(queue_free())
	print("REMOVED")
	call_deferred("queue_free")
	#timer.get_parent().queue_free()
	pass # Replace with function body.
#func _on_timer_ready() -> void:
	#timer.start()
	#pass # Replace with function body.

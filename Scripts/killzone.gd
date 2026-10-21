extends Area3D
class_name Killzone
@onready var timer: Timer = $Timer
@onready var damage_buffer: Timer = $DamageBuffer
@export var current_owner = "null" 
func _setOwner(newOwner: String):
	current_owner = newOwner
func _getOwner():
	return current_owner
var can_hurt := true
func _hitboxDisable():
	monitoring = false
	monitoring = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)  
func _hitboxEnable():
	monitorable = true
	monitoring = true
	set_deferred("monitoring", true)  
	set_deferred("monitorable", true)  
func _physics_process(_delta: float) -> void:
	if not can_hurt:
		return
	if monitoring:
		for body in get_overlapping_bodies():
			if (body.name != current_owner):
				var player := body as Player
				if body is Enemy:
					body.queue_free()
				if body is Player:
					hurt(player)
					break

func hurt(player: Player) -> void:
	player.setHealth(player.getHealth() - 1)
	print(player.getHealth())
	can_hurt = false

	if player.getHealth() <= 0:
		print("YOU DIED")
		timer.start()
	else:
		damage_buffer.start()

func _on_timer_timeout() -> void:
	print("RELOADING GAME")
	get_tree().reload_current_scene()

func _on_damage_buffer_timeout() -> void:
	can_hurt = true

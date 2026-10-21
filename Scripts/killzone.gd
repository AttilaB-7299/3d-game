extends Area3D

@onready var timer: Timer = $Timer
@onready var damage_buffer: Timer = $DamageBuffer

var can_hurt := true

func _physics_process(_delta: float) -> void:
	if not can_hurt:
		return

	for body in get_overlapping_bodies():
		var player := body as Player
		if player != null:
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

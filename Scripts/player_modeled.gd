extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $".."
func _stopAnim():
	animation_player.stop()
func _playAnim(anim_name: String):
	var user = player as Player
	var attack_count = user.attackAmount() +1
	if (anim_name == animation_player.current_animation):
		pass
	elif (anim_name == "attack"):
		if (attack_count > 1 and attack_count < 4):
			animation_player.play("combo%s" % attack_count)
			pass
		else:
			animation_player.play("hit")
			pass
	else:
		animation_player.stop()
		animation_player.play(anim_name)

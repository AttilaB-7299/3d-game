extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $".."
func _stopAnim():
	animation_player.stop()
func _animBlend(anim_name: String, blendTime: float):
	if (anim_name == "attack"):
		animation_player.play("hit", blendTime)
	else:
		animation_player.play(anim_name, blendTime)
func _playAnim(anim_name: String):
	var user = player as Player
	if (anim_name == animation_player.current_animation):
		pass
	elif (anim_name == "attack"):
		#var attack_count = user.attackAmount() +1
		#if (attack_count > 1 and attack_count < 4):
			#animation_player.play("combo%s" % attack_count)
			#pass
		#else:
			#animation_player.play("hit")
			#pass
		animation_player.play("hit", 0.2)
	else:
		animation_player.stop()
		animation_player.play(anim_name)

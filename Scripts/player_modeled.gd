extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _playAnim(anim_name: String):
	if (anim_name == animation_player.current_animation):
		pass
	else:
		animation_player.stop()
		animation_player.play(anim_name)

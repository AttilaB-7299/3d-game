extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _stopAnim() -> void:
	if animation_player:
		animation_player.stop()

func _animBlend(anim_name: String, blendTime: float) -> void:
	if not animation_player:
		animation_player = get_node_or_null("AnimationPlayer") as AnimationPlayer
		if not animation_player:
			print_debug("AnimationPlayer node not found!")
			return
#
	#if anim_name == "attack":
		#animation_player.play("hit", blendTime)
	#else:
	animation_player.play(anim_name, blendTime)

func _playAnim(anim_name: String) -> void:
	if not animation_player:
		return
	if anim_name == animation_player.current_animation:
		pass
	#elif anim_name == "attack":
		#animation_player.play("hit", 0.2)
	else:
		#animation_player.stop()
		animation_player.play(anim_name)
		#print("PLAYING '" + anim_name + "ANIMATION")

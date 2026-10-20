extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _playAnim(String):
	if (String == "walk" || String == "Walk" || String == "WALK"):
		animation_player.play("animation")
	else:
		animation_player.play(String)

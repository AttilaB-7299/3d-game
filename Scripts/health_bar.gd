extends CanvasLayer

@onready var health_bar: ProgressBar = $healthBar
#var player: Player
@export var player: Player

func _ready() -> void:
	health_bar.show_percentage = false
	#var red := StyleBoxFlat.new()
	#red.bg_color = Color(0.783, 0.0, 0.088, 1.0)
	#red.set_corner_radius_all(6)
	var green := StyleBoxFlat.new()
	green.bg_color = Color(0.0, 0.57, 0.277, 1.0)
	green.set_corner_radius_all(6)
	var gray := StyleBoxFlat.new()
	gray.bg_color = Color(0.39, 0.39, 0.39, 1.0)
	gray.set_corner_radius_all(6)
	health_bar.add_theme_stylebox_override("background", gray)
	health_bar.add_theme_stylebox_override("fill", green)
	await get_tree().process_frame
	#player = get_tree().get_first_node_in_group("player") as Player
	
	health_bar.max_value = player.maxHealth()
	health_bar.value = player.getHealth()
	
	
	player.connect("took_damage", func():
		#print_debug("HERE")\
		print_debug("emitted :)")
		var red := StyleBoxFlat.new()
		red.bg_color = Color(0.783, 0.0, 0.088, 1.0)
		red.set_corner_radius_all(6)
		gray.bg_color = Color(0.39, 0.39, 0.39, 1.0)
		gray.set_corner_radius_all(6)
		health_bar.add_theme_stylebox_override("background", red)
		print_debug("SETTING RED")
		await get_tree().create_timer(0.25).timeout
		health_bar.add_theme_stylebox_override("background", gray)
		print_debug("REVERTING TO GRAY")
		)

func _process(_delta: float) -> void:
	#var red := StyleBoxFlat.new()
	#red.bg_color = Color(0.783, 0.0, 0.088, 1.0)
	#red.set_corner_radius_all(6)
	#var gray := StyleBoxFlat.new()
	#gray.bg_color = Color(0.39, 0.39, 0.39, 1.0)
	#gray.set_corner_radius_all(6)
	health_bar.value = player.getHealth()
	#if (player.took_damage):
		#health_bar.add_theme_stylebox_override("background", red)
		#await get_tree().create_timer(2.0).timeout
		#health_bar.add_theme_stylebox_override("background", gray)


func upgrade_max_health(bonus_amount: int) -> void:
	player.changeMaxHealth(bonus_amount)
	health_bar.max_value = player.maxHealth()

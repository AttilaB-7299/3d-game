extends CanvasLayer

@onready var health_bar: ProgressBar = $healthBar
var player: Player

func _ready() -> void:
	await get_tree().process_frame
	health_bar.show_percentage = false
	player = get_tree().get_first_node_in_group("player") as Player
	health_bar.max_value = player.maxHealth()
	health_bar.value = player.getHealth()

func _process(_delta: float) -> void:
	health_bar.value = player.getHealth()

func upgrade_max_health(bonus_amount: int) -> void:
	player.changeMaxHealth(bonus_amount)
	health_bar.max_value = player.maxHealth()

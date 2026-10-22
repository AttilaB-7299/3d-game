extends CanvasLayer

@onready var health_bar: ProgressBar = $healthBar
@onready var damage_bar: ProgressBar = $DamageBar
#var player: Player
@export var player: Player

func _ready() -> void:
	health_bar.max_value = player.maxHealth()
	health_bar.value = player.getHealth()
	damage_bar.max_value = player.maxHealth()
	damage_bar.value = health_bar.value
	
	player.connect("took_damage", func():
		health_bar.value = player.getHealth()
	)

func _process(_delta: float) -> void:
	damage_bar.value = lerp(damage_bar.value, health_bar.value, _delta * 5)
	if damage_bar.value - health_bar.value < 0.1:
		damage_bar.value = health_bar.value

func upgrade_max_health(bonus_amount: int) -> void:
	player.changeMaxHealth(bonus_amount)
	health_bar.max_value = player.maxHealth()

extends CanvasLayer

@export var health_component: HealthComponent

@onready var health_bar: ProgressBar = $healthBar
@onready var damage_bar: ProgressBar = $DamageBar

func _ready() -> void:
	health_bar.max_value = health_component.max_health
	health_bar.value = health_bar.max_value
	damage_bar.max_value = health_bar.max_value
	damage_bar.value = health_bar.value

	health_component.current_health_changed.connect(func(_by: int):
		health_bar.value = health_component.current_health
	)

	health_component.max_health_changed.connect(func(_by: int):
		health_bar.max_value = health_component.max_health
	)

func _process(_delta: float) -> void:
	damage_bar.value = lerp(damage_bar.value, health_bar.value, _delta * 5)
	if damage_bar.value - health_bar.value < 0.1:
		damage_bar.value = health_bar.value

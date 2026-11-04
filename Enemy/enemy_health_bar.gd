extends ProgressBar

@export var health_component: HealthComponent

func _ready() -> void:
	max_value = health_component.max_health
	value = health_component.current_health

	health_component.current_health_changed.connect(func(by: int):
		value = health_component.current_health
		show()
	)

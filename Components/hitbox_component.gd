class_name HitBoxComponent extends Area3D

signal attack_box_entered(attackbox: AttackBoxComponent)
signal attack_box_exited(attackbox: AttackBoxComponent)
signal hit(by: int)

@export var health_component: HealthComponent

func _ready() -> void:
	connect("area_entered" , func(area: Area3D):
		if area is AttackBoxComponent:
			attack_box_entered.emit(area)
	)
	connect("area_exited" , func(area: Area3D):
		if area is AttackBoxComponent:
			attack_box_exited.emit(area)
	)


# should be called by attackbox_compoenent
func deal_damage(ammount: int):
	if health_component:
		hit.emit(ammount)
		health_component.current_health -= ammount


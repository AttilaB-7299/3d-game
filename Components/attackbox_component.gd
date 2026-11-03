class_name AttackBoxComponent extends Area3D

signal hitbox_entered(hitbox: HitBoxComponent)
signal hitbox_exited(hitbox: HitBoxComponent)
signal attack(by: int)

@export var attack_damage := 1
@export var attack_cooldown: float

var hitboxes_in_area: Array[HitBoxComponent]

var enabled := true
var can_attack := true:
	set(new_val):
		if new_val == false && can_attack == true:
			can_attack = false
			await get_tree().create_timer(attack_cooldown).timeout
			can_attack = true
		elif new_val == true:
			can_attack = new_val

func _ready() -> void:
	connect("area_entered" , func(area: Area3D):
		if area is HitBoxComponent:
			hitbox_entered.emit(area)
			hitboxes_in_area.append(area)
	)

	area_exited.connect(func(area: Area3D):
		if area is HitBoxComponent:
			hitbox_exited.emit(area)
			hitboxes_in_area.erase(area)
	)

func _physics_process(delta: float) -> void:
	if can_attack && hitboxes_in_area.size() && enabled:
		attack.emit(attack_damage)
		hitboxes_in_area.pick_random().deal_damage(attack_damage)
		can_attack = false

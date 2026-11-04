extends CharacterBody3D
class_name Enemy

@onready var attackbox_component: AttackBoxComponent = $AttackBoxComponent
@onready var nono_zone: Area3D = $NoNoZone
@onready var blockbench_export: Node3D = $blockbench_export

@export var speed := 5.0
@export var attack_cooldown: float

var player: Player
var player_found = true


enum States {
	IDLE,
	CHASING,
	ATTACKING,
}
var current_state := States.IDLE


func _ready():
	pass

func _physics_process(_delta: float) -> void:

	if !is_on_floor():
		velocity.y += 10 * _delta * get_gravity().y
	else:
		velocity.y = 0

	match current_state:
		States.IDLE:
			handle_idle_state()
		States.CHASING:
			handle_chasing_state(_delta)
		States.ATTACKING:
			handle_attacking_state(_delta)
	move_and_slide()



	# _handle_possible_state_change()
# func _handle_possible_state_change():
# 	if (playerFound && !inRange):
# 		state = "chasing"
# 		blockbench_export._playAnim("walk")
# 	if (playerFound && inRange):
# 		blockbench_export._playAnim("stab")
# 	else:
# 		state = "idle"
# 		blockbench_export._playAnim("idle")


func handle_idle_state():
	blockbench_export._playAnim("idle")
	

func handle_chasing_state(delta: float):
	blockbench_export._playAnim("walk")
	look_at(player.global_position)
	rotation.x = 0
	position = position.move_toward(player.position, delta * speed)

func handle_attacking_state(delta: float):
	pass
	# if attackbox_component.can_attack:
	# 	blockbench_export._playAnim("stab")


func _on_no_no_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		player_found = true
		current_state = States.CHASING


func _on_no_no_zone_body_exited(body: Node3D) -> void:
	if body is Player:
		player_found = false
		current_state = States.IDLE

	
# func _on_attack_box_hit_by_hitbox(hitbox: Variant) -> void:
# 	current_state = States.ATTACKING

func _on_attack_box_component_hitbox_entered(hitbox: HitBoxComponent) -> void:
	current_state = States.ATTACKING


func _on_attack_box_component_hitbox_exited(hitbox: HitBoxComponent) -> void:
	if player_found:
		current_state = States.CHASING
	else:
		current_state = States.IDLE

func _on_attack_box_component_attack(by: int) -> void:
	blockbench_export._playAnim("stab")


func _on_health_component_die() -> void:
	print_debug("ENEMY DIED")
	queue_free()

func _on_health_component_current_health_changed(by: int) -> void:
	print_debug("ENEMY HEALTH: " + str($HealthComponent.current_health))

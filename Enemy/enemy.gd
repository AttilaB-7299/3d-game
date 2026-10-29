extends CharacterBody3D
class_name Enemy

@onready var killzone: Killzone = $Killzone
@onready var nono_zone: Area3D = $NoNoZone

@export var speed := 5.0

var player: Player

@onready var blockbench_export: Node3D = $blockbench_export

enum States {
	IDLE,
	CHASING,
	ATTACKING,
}

var current_state := States.IDLE

# var state := "chasing"
var playerFound = true
var inRange = false
func _ready():
	killzone._setOwner("Enemy")
	#set_deferred("monitoring", true)  
	#set_deferred("monitorable", true)  
	#killzone._hitboxEnable()
	#print("ENABLED ENEMY HITBOX")
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
			handle_attacking_state()
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

func handle_attacking_state():
	pass


func _on_no_no_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		current_state = States.CHASING


func _on_no_no_zone_body_exited(body: Node3D) -> void:
	if body is Player:
		current_state = States.IDLE

	

extends CharacterBody3D
class_name Enemy
@onready var killzone: Killzone = $Killzone
@onready var blockbench_export: Node3D = $blockbench_export
var state := "chasing"
var playerFound = true
var inRange = false
func _ready():
	killzone._setOwner("Enemy")
	#set_deferred("monitoring", true)  
	#set_deferred("monitorable", true)  
	#killzone._hitboxEnable()
	#print("ENABLED ENEMY HITBOX")
func _physics_process(_delta: float) -> void:
	_handle_possible_state_change()
func _handle_possible_state_change():
	if (playerFound && !inRange):
		state = "chasing"
		blockbench_export._playAnim("walk")
	if (playerFound && inRange):
		blockbench_export._playAnim("stab")
	else:
		state = "idle"
		blockbench_export._playAnim("idle")

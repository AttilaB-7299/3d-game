extends CharacterBody3D
class_name Enemy
@onready var killzone: Killzone = $Killzone
func _ready():
	killzone._setOwner("Enemy")
	#set_deferred("monitoring", true)  
	#set_deferred("monitorable", true)  
	#killzone._hitboxEnable()
	#print("ENABLED ENEMY HITBOX")

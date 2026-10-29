@tool
class_name Item extends Area3D

@export var item_name: String
@export var mesh: MeshInstance3D
@export var item_pickup_range := 0.5 : set = update_pickup_range

@export_subgroup("Inventory")
@export var icon: Texture2D# Textre Rect

var pickup_coll_shape: CollisionShape3D

func _ready() -> void:
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

	connect("body_entered", _on_body_entered)

	pickup_coll_shape = CollisionShape3D.new()
	pickup_coll_shape.shape = SphereShape3D.new()
	pickup_coll_shape.shape.radius = item_pickup_range
	pickup_coll_shape.debug_color = Color(0,0,1, .75)
	# pickup_coll_shape.add_to_group("da coll shape")
	add_child(pickup_coll_shape)

	if Engine.is_editor_hint():
		var pickup_mesh := MeshInstance3D.new()
		pickup_mesh.mesh = SphereMesh.new()
		pickup_mesh.mesh.radius = item_pickup_range
		pickup_mesh.mesh.height = item_pickup_range * 2

		pickup_mesh.add_to_group("da mesh")
		add_child(pickup_mesh)
		pickup_mesh.material_override = StandardMaterial3D.new()
		pickup_mesh.material_override.albedo_color = Color(0,0,1, 0.3)
		pickup_mesh.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	
# func _physics_process(_delta: float) -> void:
# 	pass

func update_pickup_range(new_val: float):
	item_pickup_range = new_val

	if !pickup_coll_shape:
		return

	pickup_coll_shape.shape.radius = item_pickup_range


	if Engine.is_editor_hint():
		for child in get_children():
			if child.is_in_group("da mesh"):
				child.mesh.radius = item_pickup_range
				child.mesh.height = item_pickup_range * 2
				break


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		print("ITEM COLLECTED")
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, false)
		hide()

		pickup_coll_shape.disabled = true

		# TODO: move this to player

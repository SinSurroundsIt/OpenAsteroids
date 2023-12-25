extends Node2D
class_name Laser

var velocity: Vector2
var source: Node2D

@export var speed: float
@export var max_range: float

var _lifetime_travel: float

@onready var _raycast: RayCast2D = $RayCast2D


func _ready() -> void:
	_raycast.add_exception(source)


func _physics_process(delta) -> void:
	var frame_move_vector: Vector2 = -transform.y * speed + velocity * delta 
	_raycast.target_position = to_local(global_position + frame_move_vector)
	_raycast.force_raycast_update()
	
	var collider: Node2D = _raycast.get_collider()
	if collider != null:
		if collider.has_method("take_weapon_damage"):
			collider.take_weapon_damage()
		var _impact_pos: Vector2 = _raycast.get_collision_point()
		var _impact_normal: Vector2 = _raycast.get_collision_normal()
		Events.asteroid_laser_hit.emit(_impact_pos, _impact_normal)
		queue_free()
	
	global_position += frame_move_vector
	_lifetime_travel += frame_move_vector.length()
	
	if _lifetime_travel > max_range:
		queue_free()

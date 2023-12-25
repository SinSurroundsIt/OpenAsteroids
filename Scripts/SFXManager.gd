extends Node

@onready var asteroid_explosion_tscn = preload("res://Scenes/asteroid_explosion.tscn")
@onready var laser_impact_tscn = preload("res://Scenes/laser_impact.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.asteroid_explode.connect(_Asteroid_Explosion)
	Events.ship_explode.connect(_Ship_Explosion)
	Events.asteroid_laser_hit.connect(_Laser_Impact)


func _Asteroid_Explosion(pos: Vector2, _vel: Vector2):
	var explosion = asteroid_explosion_tscn.instantiate()
	add_child(explosion)
	explosion.position = pos

func _Ship_Explosion(pos: Vector2):
	var displacement_vector: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(8, 16)
	var new_pos: Vector2 = pos + displacement_vector
	var explosion = asteroid_explosion_tscn.instantiate()
	add_child(explosion)
	explosion.position = new_pos

func _Laser_Impact(_pos: Vector2, _normal: Vector2):
	var impact = laser_impact_tscn.instantiate()
	add_child(impact)
	impact.position = _pos
	var _temp_rot: float = Vector2(cos(impact.rotation), sin(impact.rotation)).angle_to(_normal)
	impact.rotation = _temp_rot

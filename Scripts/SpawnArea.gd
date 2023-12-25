extends Area2D

var _b_repulse: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.set_spawn_safety.connect(_Set_Repulse)


func _physics_process(_delta):
	if _b_repulse:
		_Repulse_Bodies()


func _Repulse_Bodies() -> void:
	var bodies: Array = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("asteroids"):
			var asteroid: Asteroid = body
			var direction = _Get_Direction(position, asteroid.position)
			asteroid.apply_central_force(direction * GameSettings.repulse_strength * asteroid.mass)

func _Get_Direction(from: Vector2, to: Vector2) -> Vector2:
	var direction: Vector2
	direction = (to - from).normalized()
	return direction

func _Set_Repulse(repulse: bool):
	_b_repulse = repulse

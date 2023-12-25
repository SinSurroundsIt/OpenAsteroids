extends Area2D

class_name Shield

@export var max_shield_strength: float = 3
@export var shield_charge_delay: float = 3
@export_range(1, 20, 1 )
var shield_recharge_time: float = 20

var shield_fade_time: float = 0.4
var _shield_strength: float
var _shield_brightness: float = 100

@onready var shield_light: PointLight2D = get_node("shield_light")
@onready var shield_down_sfx: GPUParticles2D = get_node("shield_down_sfx")
@onready var ship: Ship = get_parent()
@onready var shield_timer: Timer = get_node("shield_charge_timer")

var _b_ship_invuln: bool = false
var _b_ship_dead: bool = false




# Called when the node enters the scene tree for the first time.
func _ready():
	_shield_strength = max_shield_strength
	Events.update_shield_strength.emit(max_shield_strength, _shield_strength)
	shield_timer.timeout.connect(Shield_Timer_Stop)


# Called every frame. 'delta' is the elapsed time since the previous frame.aa
func _process(delta):
	if !_b_ship_dead:
		if _shield_strength < max_shield_strength:
			_shield_strength += delta / shield_recharge_time
		clampf(_shield_strength, 0, max_shield_strength)
		Events.update_shield_strength.emit(max_shield_strength, _shield_strength)
		if shield_light.energy > 0:
			shield_light.energy -= delta * _shield_brightness / shield_fade_time
		if shield_light.energy < 0:
			shield_light.energy = 0.0
	if _b_ship_dead:
		shield_light.energy = 0.0

func _on_body_entered(body):
	if !_b_ship_dead:
		var object: Node2D = body
		if object.is_in_group("asteroids"):
			var asteroid: Asteroid = object
			_Damage_Shield(asteroid, asteroid.size, asteroid.position)

func _Damage_Shield(asteroid: Asteroid, size: int, _pos: Vector2):
	
	var impact_vel: Vector2 = asteroid.linear_velocity - ship.linear_velocity
	var impact_perp_vel: Vector2 = Vector2(impact_vel.y, -impact_vel.x).normalized()
	
	if _b_ship_invuln:
		shield_light.energy = _shield_brightness
		asteroid.apply_whack((impact_vel.reflect(impact_perp_vel) * asteroid.mass * 1.5))
		Events.shield_hit.emit()
	
	elif size == 3:
		shields_down()
			
	elif size == 2:
		if _shield_strength > size:
			_shield_strength -= size
			Events.update_shield_strength.emit(max_shield_strength, _shield_strength)
			shield_light.energy = _shield_brightness
			asteroid.apply_whack((impact_vel.reflect(impact_perp_vel) * asteroid.mass * 1.5))
			Events.shield_hit.emit()
		else:
			shields_down()
			
	elif size == 1:
		if _shield_strength > size:
			_shield_strength -= size
			Events.update_shield_strength.emit(max_shield_strength, _shield_strength)
			shield_light.energy = _shield_brightness
			asteroid.apply_whack((impact_vel.reflect(impact_perp_vel) * asteroid.mass * 1.5))
			Events.shield_hit.emit()
			asteroid.destroy()
		else:
			shields_down()
		
func shields_down():
		_shield_strength = 0.0
		Events.update_shield_strength.emit(max_shield_strength, _shield_strength)
		shield_down_sfx.emitting = true
		shield_timer.start(shield_charge_delay)
		Events.shield_timer_start.emit()
		Events.shield_down.emit()
		
func Shield_Timer_Stop():
	Events.shield_timer_stop.emit()

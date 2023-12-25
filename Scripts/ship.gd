extends RigidBody2D

class_name Ship

@export var max_rotation_velocity: float = 1.0
@export var max_linear_velocity: float = 10.0
@export var thruster_strength: float = 2.0
@export var rotator_strength: float = 50
@export var laser_rof: float = 0.15

@export var shield_strength: int = 4

@export var explosions_to_die: int = 4
@export var base_time_between_explosions: float = 1.25

var _local_velocity: Vector2
var _move_input: float = 0.0
var _rot_input: float = 0.0

@onready var project_resolution:Vector2 = get_viewport().content_scale_size
@onready var laser_cooldown: Timer = get_node("laser_cooldown")
@onready var gun_point_0: Node2D = get_node("gun_points/gun_point_0")
@onready var gun_point_1: Node2D = get_node("gun_points/gun_point_1")
var _current_gun_point: int = 0

var _b_shooting: bool = false

@onready var engine_sound: AudioStreamPlayer = get_node("engine_sound")
@onready var thruster: Sprite2D = get_node("thrust_sprite")
@onready var right_thrust: Sprite2D = get_node("turn_sprites/right_thrust")
@onready var left_thrust: Sprite2D = get_node("turn_sprites/left_thrust")

@onready var hull_collider: CollisionShape2D = get_node("hull_collider")

@onready var shield: Shield = get_node("shield")

@onready var explode_timer: Timer = get_node("explode_timer")

var _b_ship_invuln: bool = false

var _b_ship_dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	thruster.visible = false
	_Set_Ship_Invuln(true)
	shield.Shield_Timer_Stop()
	explode_timer.timeout.connect(_Explosion_Timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !_b_ship_dead:
		if Input.is_action_pressed("up"):
			if _b_ship_invuln: _Set_Ship_Invuln(false)
			_move_input = 1.0
			thruster.visible = true
			if !engine_sound.playing:
				engine_sound.play()
		else:
			if thruster.visible == true:
				thruster.visible = false
			_move_input = 0.0
			if engine_sound.playing:
				engine_sound.stop()
				
		_rot_input = Input.get_axis("left", "right")
		
		if Input.is_action_pressed("right"):
			right_thrust.visible = true
		elif right_thrust.visible:
			right_thrust.visible = false
			
		if Input.is_action_pressed("left"):
			left_thrust.visible = true
		elif left_thrust.visible:
			left_thrust.visible = false
		
		if Input.is_action_pressed("shoot"):
			if _b_ship_invuln: _Set_Ship_Invuln(false)
			_b_shooting = true
		else:
			_b_shooting = false
	else:
		_b_shooting = false
		_rot_input = 0.1
		_move_input = 0.1

func _physics_process(delta):
	_update_state(delta)
	apply_central_impulse(-transform.y * calc_linear_force() * mass)
	apply_torque_impulse(_rot_input * rotator_strength * mass) 

func _integrate_forces(state):
	state.transform = _Screen_Wrap(state.transform)

func calc_linear_force() -> float:
	var _new_force: float 
	_new_force = _move_input * thruster_strength
	return _new_force

func _update_state(_dt: float) -> void:
	_local_velocity = global_transform.basis_xform_inv(linear_velocity)
 
func _Screen_Wrap(_transform_in: Transform2D) -> Transform2D:
	var _xform: Transform2D = _transform_in   
	_xform.origin.x = wrapf(position.x, 0.0, project_resolution.x)
	_xform.origin.y = wrapf(position.y, 0.0, project_resolution.y)
	return _xform
	

func _Fire_Laser() -> void:
	if _current_gun_point == 0:
		Events.fire_laser.emit(self, gun_point_0.global_position, linear_velocity, rotation)
	else:
		Events.fire_laser.emit(self, gun_point_1.global_position, linear_velocity, rotation)
	laser_cooldown.start(laser_rof)
	if _current_gun_point == 0:
		_current_gun_point = 1
	else:
		_current_gun_point = 0

func _on_laser_cooldown_timeout():
	if _b_shooting:
		_Fire_Laser()

func _on_body_shape_entered(_body_rid, body, _body_shape_index, local_shape_index):
		print(body)
		var shape = self.shape_owner_get_owner(self.shape_find_owner(local_shape_index))
		if shape == hull_collider:
				var asteroid: Asteroid = body
				if asteroid.size > 1 && !_b_ship_invuln:
					_Ship_Kill()

				
func _Set_Ship_Invuln(is_invuln: bool):
	_b_ship_invuln = is_invuln
	shield._b_ship_invuln = is_invuln
	
func _Ship_Kill():
	if !_b_ship_dead:
		_b_ship_dead = true
		shield._b_ship_dead = true
		_Make_Explosion(position)
	else:
		_Ship_Explode(position)

func _Ship_Explode(_pos: Vector2):
	Events.ship_explode.emit(_pos)
	Events.player_died.emit()
	queue_free()

func _Explosion_Timer():
	_Make_Explosion(position)

func _Make_Explosion(_pos: Vector2):
	Events.ship_explode.emit(_pos)
	if explosions_to_die > 0:
		explode_timer.start(base_time_between_explosions + randf_range(-0.25, 0.25))
		explosions_to_die -= 1
	else:
		_Ship_Explode(position)

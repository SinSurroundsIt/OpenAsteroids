extends Node

@onready var _asteroid_tscn = preload("res://Scenes/asteroid.tscn")
@onready var project_resolution:Vector2 = get_viewport().content_scale_size

#Large Asteroid Sprites:
@onready var large_asteroid_sprite1: Texture2D = preload("res://Images/Asteroids/meteorBrown_big1.png")
@onready var large_asteroid_sprite2: Texture2D = preload("res://Images/Asteroids/meteorBrown_big2.png")
@onready var large_asteroid_sprite3: Texture2D = preload("res://Images/Asteroids/meteorBrown_big3.png")
@onready var large_asteroid_sprite4: Texture2D = preload("res://Images/Asteroids/meteorBrown_big4.png")

#Medium Asteroid Sprints:
@onready var med_asteroid_sprite1: Texture2D = preload("res://Images/Asteroids/meteorBrown_med1.png")
@onready var med_asteroid_sprite2: Texture2D = preload("res://Images/Asteroids/meteorBrown_med3.png")

#Small Asteroid Sprints:
@onready var small_asteroid_sprite1: Texture2D = preload("res://Images/Asteroids/meteorBrown_small1.png")
@onready var small_asteroid_sprite2: Texture2D = preload("res://Images/Asteroids/meteorBrown_small2.png")

@onready var large_asteroid_sprite_array: Array = [large_asteroid_sprite1, large_asteroid_sprite2, large_asteroid_sprite3, large_asteroid_sprite4]
@onready var med_asteroid_sprite_array: Array = [med_asteroid_sprite1, med_asteroid_sprite2]
@onready var small_asteroid_sprite_array: Array = [small_asteroid_sprite1, small_asteroid_sprite2]

@export var max_asteroid_count: int = 10
var _current_large_asteroids: int

@export var asteroid_spawn_time: float = 5
var _current_spawn_time: float

var _player_ship: Ship

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Spawn_Asteroid(max_asteroid_count, 3)
	
	Events.asteroid_destroyed.connect(_Asteroid_Destroyed)
	Events.new_player_ship.connect(_Set_Player_Ship)
	Events.level_start.connect(_New_Level)
	Events.get_asteroids.connect(_Get_Asteroids_Group)
	
	_current_spawn_time = asteroid_spawn_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	#_Update_Asteroid_Timer(_delta)
	pass

func Spawn_Asteroid(_number: int, _size: int) -> void: 
	for i in _number:
		#Spawn the asteroid offscreen so we don't see it appear.
		var _spawn_point: Vector2 = _Get_Offscreen_Spawn_Point()
		var _asteroid: Asteroid = _Spawn_Asteroid_At_Position(_size, _spawn_point)
		
		#Find a point on a circle around the player and get the vector to it.
		var _player_spawn_circle: Vector2 = _Get_Position_On_Circle(_player_ship.position, randf_range(50, 100))
		var _spawn_circle_vector: Vector2 = _Get_Direction(_player_spawn_circle, _asteroid.position).normalized()
		
		#Introduce some turbulence.
		var _turbulence_vector: Vector2 = Vector2(randf_range(-GameSettings.spawn_turbulence * _size, GameSettings.spawn_turbulence * _size), randf_range(-GameSettings.spawn_turbulence * _size, GameSettings.spawn_turbulence * _size)).normalized()
		var _turbulence_influence: float = 0.3
		
		#Combine the two.
		var _whack_vector: Vector2 = (_spawn_circle_vector * (1 - _turbulence_influence) + _turbulence_vector * _turbulence_influence).normalized()

		#Hit the rock towards the player, kinda.
		_asteroid.apply_whack(_whack_vector * _asteroid.mass * randf_range(50, 100))
		
func _Spawn_Asteroid_At_Position(size: int, pos: Vector2) -> Asteroid:
	var asteroid: Asteroid = _asteroid_tscn.instantiate()
	var texture: Texture2D
	if size == 3:
		texture = large_asteroid_sprite_array.pick_random()
		_current_large_asteroids += 1
	elif size == 2:
		texture = med_asteroid_sprite_array.pick_random()
	else:
		texture = small_asteroid_sprite_array.pick_random()
	asteroid.texture = texture
	asteroid.size = size
	add_child(asteroid)
	asteroid.position = pos
	Events.asteroid_spawned.emit()
	return asteroid

#Commented out as we're now spawning on level end.
#func _Update_Asteroid_Timer(delta: float):
#	if _current_spawn_time > 0:
#		_current_spawn_time -= delta
#	if _current_spawn_time <= 0:
#		_Maybe_Spawn_Asteroids()
#		_current_spawn_time = asteroid_spawn_time

#Commented out as we're now spawning on level end.		
#func _Maybe_Spawn_Asteroids():
#	var _number_of_asteroids_to_spawn: int
#	if _current_large_asteroids < max_asteroid_count:
#		_number_of_asteroids_to_spawn = max_asteroid_count - _current_large_asteroids
#		for i in _number_of_asteroids_to_spawn:
#			var spawn_point = _Get_Offscreen_Spawn_Point()
#			var asteroid: Asteroid = _Spawn_Asteroid_At_Position(3, spawn_point)
#			if !_player_ship == null:
#				asteroid.apply_whack(_Get_Direction(asteroid.position, _player_ship.position) * asteroid.mass * randf_range(100, 200))
#			else:
#				asteroid.apply_whack(_Get_Direction(asteroid.position, project_resolution / 2) * asteroid.mass * randf_range(50, 100))
#			print("Spawning Asteroid at position: " + str(asteroid.position))

func _Asteroid_Destroyed(size: int, pos: Vector2, vel: Vector2) -> void:
	var asteroid: Asteroid
	var vel_in: Vector2 = vel
	var temp_vel: Vector2 = vel
	if size == 3:
		_current_large_asteroids -= 1
	if size > 1:
		for i in 2:
			var temp_side: float
			if i == 1:
				temp_side = 1
			else:
				temp_side = -1
			var temp_vector: Vector2 = Vector2(temp_side * 24, temp_side * 24)
			var temp_speed: float = vel.length()
			asteroid = _Spawn_Asteroid_At_Position(size - 1, pos + temp_vector)
			#temp_vel.x += randf_range(0.75, 1.25)
			#temp_vel.y += randf_range(0.75, 1.25)
			temp_vel = temp_vel.normalized()
			var split_vel: Vector2 = _Get_Direction(asteroid.position, pos)
			var split_factor: float = randf()
			var new_vel: Vector2 = (temp_vel * split_factor + split_vel * (1 - split_factor)).normalized()
			asteroid.apply_whack((new_vel * temp_speed) * (size - 1) * asteroid.mass * randf_range(0.5, 1.5))
			asteroid.apply_spin(randf_range(-100, 100) * asteroid.mass)
			temp_vel = vel_in
	Events.asteroid_explode.emit(pos, vel)
			
func _Get_Offscreen_Spawn_Point() -> Vector2:
	var quadrant: int = randi_range(0, 3)
	var spawn_point: Vector2 = Vector2.ZERO
	
	#Top of screen
	if quadrant == 0:
		spawn_point.y = -50.0
		spawn_point.x = randf_range(-50.0, project_resolution.x + 50.0)
	#Right of screen
	elif quadrant == 1:
		spawn_point.y = randf_range(-50.0, project_resolution.y + 50.0)
		spawn_point.x = project_resolution.x + 50.0
	#Bottom of screen
	elif quadrant == 2:
		spawn_point.y = project_resolution.y + 50.0
		spawn_point.x = randf_range(-50.0, project_resolution.x + 50.0)
	#Left of screen
	else:
		spawn_point.y = randf_range(-50.0, project_resolution.y + 50.0)
		spawn_point.x = -50.0
		
	return spawn_point

func _Set_Player_Ship(ship: Ship) -> void:
	_player_ship = ship
	
func _Get_Direction(from: Vector2, to: Vector2) -> Vector2:
	var direction: Vector2
	direction = (from - to).normalized()
	return direction
	
func _Get_Position_On_Circle(position: Vector2, radius: float) -> Vector2:
	var _radius_vector = Vector2(radius, 0)
	var _random_rotation: float = randf_range(0, 2 * PI)
	var _new_pos: Vector2 = position + _radius_vector.rotated(_random_rotation)
	return _new_pos

func _New_Level(_asteroids: int, _level: int) -> void:
	Spawn_Asteroid(_asteroids, 3)

func _Get_Asteroids_Group() -> void:
	var _asteroids: Array = get_tree().get_nodes_in_group("asteroids")
	Events.send_asteroids.emit(_asteroids)

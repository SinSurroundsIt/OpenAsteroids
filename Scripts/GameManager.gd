extends Node

@export var starting_lives: int
var lives: int

@onready var ship_tscn = preload("res://Scenes/ship.tscn")
@onready var project_resolution:Vector2 = get_viewport().content_scale_size
@onready var canvas: CanvasLayer = get_parent().get_node("CanvasLayer")
@onready var pause_menu_tscn = preload("res://Scenes/pause_menu.tscn")
@onready var gameover_menu_tscn = preload("res://Scenes/game_over.tscn")

var player_ship: Ship

var _score: int = 0

var _level: int = 1

var _current_asteroids: int = 0
var _level_asteroids: int = 0


func _ready() -> void:
	Events.player_died.connect(_Player_Died)
	Events.asteroid_destroyed.connect(_Destroyed_Asteroid)
	Events.asteroid_spawned.connect(_Asteroid_Spawned)
	Events.new_game.connect(_New_Game)
	
	_New_Game()


func _process(_delta) -> void:
	if Input.is_action_just_released("menu"):
		if !get_tree().paused:
			var pause = pause_menu_tscn.instantiate()
			canvas.add_child(pause)
			Events.game_state_changed.emit(true)
		else:
			Events.game_state_changed.emit(false)
	if Input.is_action_just_released("game_over"):
		_Update_Lives(-3)
			

func _Destroyed_Asteroid(size: int, _position: Vector2, _velocity: Vector2) -> void:
	if size == 3:
		_Update_Score(1)
	elif size == 2:
		_Update_Score(2)
	else:
		_Update_Score(3)
	_current_asteroids -= 1
	print("Asteroid Destroyed: " + str(_current_asteroids))
	if _current_asteroids == 0:
		_level += 1
		Events.update_level.emit(_level)
		var level_start_timer: Timer = Timer.new()
		level_start_timer.timeout.connect(_New_Level)
		level_start_timer.timeout.connect(level_start_timer.queue_free)
		add_child(level_start_timer)
		level_start_timer.start(2)

func _Update_Score(mod: int) -> void:
	for i in mod:
		_score += 1
		var _modulo = _score % GameSettings.add_life_divisor
		if _modulo == 0:
			_Update_Lives(1)
	Events.update_score.emit(_score)

func _Player_Died() -> void:
	_Update_Lives(-1)
	if lives > 0:
		Events.set_spawn_safety.emit(true)
		var respawn_timer: Timer = Timer.new()
		add_child(respawn_timer)
		respawn_timer.wait_time = 3.0
		respawn_timer.one_shot = true
		respawn_timer.timeout.connect(_Respawn)
		respawn_timer.start()

func _Update_Lives(mod: int) -> void:
	if lives > 0:
		lives += mod
		Events.new_lives.emit(lives)
	if lives <= 0:
		_Game_Over()

func _Spawn_Player() -> Ship:
	var ship = ship_tscn.instantiate()
	call_deferred("add_child", ship)
	var spawn_point: Vector2 = Vector2(project_resolution.x / 2, project_resolution.y / 2)
	ship.position = spawn_point
	return ship
	
func _Respawn() -> void:
		player_ship = _Spawn_Player()
		Events.new_player_ship.emit(player_ship)
		Events.set_spawn_safety.emit(false)

func _Game_Over() -> void:
	var gameover = gameover_menu_tscn.instantiate()
	canvas.add_child(gameover)
	Events.game_over.emit(_score)

func _New_Level() -> void:
	_level_asteroids = ceili(17.07 * (log(_level) / log(10)) + 1)
	Events.level_start.emit(_level, _level_asteroids)
	
func _Asteroid_Spawned() -> void:
	_current_asteroids += 1
	print(_current_asteroids)
	
func _New_Game():
	var asteroids: Array = get_tree().get_nodes_in_group("asteroids")
	for asteroid: Asteroid in asteroids:
		asteroid.queue_free()
	
	lives = starting_lives
	_score = 0
	_level = 1
	
	Events.new_lives.emit(lives)
	Events.update_score.emit(_score)
	Events.update_level.emit(_level)
	
	player_ship = _Spawn_Player()
	Events.new_player_ship.emit(player_ship)
	_New_Level()

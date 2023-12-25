extends PanelContainer

var _asteroid_sprites: Array
@onready var timer: Timer = get_node("Timer")
@onready var radar_dot = preload("res://Scenes/radar_dot.tscn")
@onready var project_resolution:Vector2 = get_viewport().content_scale_size
@export var remap_target_x: Vector2 = Vector2(4, 224)
@export var remap_target_y: Vector2 = Vector2(4, 140)

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(_On_Timer_Timeout)
	Events.send_asteroids.connect(_Update_Asteroids)
	Events.get_asteroids.emit()


func _On_Timer_Timeout():
	_Remove_Asteroids()
	Events.get_asteroids.emit()


func _Remove_Asteroids():
	for sprite in _asteroid_sprites:
		if sprite != null:
			sprite.queue_free()


func _Update_Asteroids(_asteroids: Array):
	for asteroid: Asteroid in _asteroids:
		var pos: Vector2 = asteroid.global_position
		var sprite = radar_dot.instantiate()
		_asteroid_sprites.append(sprite)
		sprite.position.x = remap(pos.x, -100, project_resolution.x + 100, remap_target_x.x, remap_target_x.y)
		sprite.position.y = remap(pos.y, -100, project_resolution.y + 100, remap_target_y.x, remap_target_y.y)
		add_child(sprite)

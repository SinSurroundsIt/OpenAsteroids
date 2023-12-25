extends Node

@onready var laser_sound: AudioStream = preload("res://Sounds/laserSmall_004.ogg")
@onready var asteroid_sound: AudioStream = preload("res://Sounds/lowFrequency_explosion_000.ogg")

@onready var shield_sound: AudioStream = preload("res://Sounds/forceField_001.ogg")
@onready var shield_down_sound: AudioStream = preload("res://Sounds/forceField_001_down.ogg")

@onready var ship_explode_sound_1: AudioStream = preload("res://Sounds/explosionCrunch_000.ogg")
@onready var ship_explode_sound_2: AudioStream = preload("res://Sounds/explosionCrunch_004.ogg")

@onready var ship_explode_library: Array = [ship_explode_sound_1, ship_explode_sound_2]

@onready var music_1: AudioStream = preload("res://Music/escape_from_metal_city.ogg")
@onready var music_2: AudioStream = preload("res://Music/techno_stargazev2.1loop.ogg")
@onready var music_3: AudioStream = preload("res://Music/Boss Battle #4 V1.wav")
@onready var music_4: AudioStream = preload("res://Music/Boss Battle 6 V1.wav")

@onready var music_library_orig: Array = [music_1, music_2, music_3, music_4]
@onready var music_library_copy: Array = music_library_orig.duplicate(true)

@onready var music_stream = AudioStreamPlayer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.fire_laser_sound.connect(_On_Events_Fire_Laser)
	Events.asteroid_destroyed_sound.connect(_On_Events_Asteroid_Destroyed)
	Events.shield_hit.connect(_On_Events_Shield_Hit)
	Events.shield_down.connect(_On_Events_Shield_Hit)
	Events.ship_explode.connect(_On_Events_Ship_Explode)
	music_stream.finished.connect(_Next_Song)
	
	_Start_Music()


func _On_Events_Asteroid_Destroyed():
	_Play_Sound_One_Off(asteroid_sound, randf_range(0.6, 0.9), randf_range(GameSettings.sfx_volume - 5, GameSettings.sfx_volume - 10))
	
func _On_Events_Fire_Laser():
	_Play_Sound_One_Off(laser_sound, randf_range(0.9, 1.1), randf_range(GameSettings.sfx_volume, GameSettings.sfx_volume - 5))
	
func _On_Events_Shield_Hit():
	_Play_Sound_One_Off(shield_sound, randf_range(0.5, 0.7), randf_range(GameSettings.sfx_volume - 5, GameSettings.sfx_volume - 10))
	
func _On_Events_Shield_Down():
	_Play_Sound_One_Off(shield_sound, randf_range(0.3, 0.5), randf_range(GameSettings.sfx_volume - 5, GameSettings.sfx_volume - 10))
	
func _On_Events_Ship_Explode(_pos: Vector2):
	var sound = ship_explode_library.pick_random()
	_Play_Sound_One_Off(sound, randf_range(0.5, 0.7), randf_range(GameSettings.sfx_volume, GameSettings.sfx_volume - 5))
	

func _Play_Sound_One_Off(sound: AudioStream, pitch, volume):
	var stream = AudioStreamPlayer.new()
	stream.stream = sound
	stream.finished.connect(stream.queue_free)

	add_child(stream)
	stream.pitch_scale = pitch
	stream.volume_db = volume
	stream.play()
	
func _Start_Music():
	var x = randi_range(0, music_library_copy.size() - 1)
	music_stream.stream = music_library_copy[x]
	music_library_copy.pop_at(x)
	add_child(music_stream)
	music_stream.volume_db = GameSettings.music_volume
	music_stream.play()
	
func _Next_Song():
	var library_size = music_library_copy.size()
	if library_size == 0:
		music_library_copy = music_library_orig.duplicate(true)
		var x = randi_range(0, library_size - 1)
		music_stream.stream = music_library_copy[x]
		music_stream.play()
	else:
		var x = randi_range(0, library_size - 1)
		music_stream.stream = music_library_copy[x]
		music_stream.play()

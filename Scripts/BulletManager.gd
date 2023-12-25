extends Node

@onready var laser_tscn = preload("res://Scenes/laser.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.fire_laser.connect(_on_Event_fire_laser)
	pass # Replace with function body.

func _on_Event_fire_laser(source_parent:Node2D, pos:Vector2, vel:Vector2, rot):
	var laser: Laser = laser_tscn.instantiate()
	laser.velocity = vel
	laser.source = source_parent
	
	add_child(laser)
	laser.position = pos
	laser.rotation = rot
	Events.fire_laser_sound.emit()

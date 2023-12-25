extends Node2D

@onready var impact_effect: GPUParticles2D = get_node("impact_effect")

# Called when the node enters the scene tree for the first time.
func _ready():
	impact_effect.emitting = true


func _on_impact_effect_finished():
	call_deferred("queue_free")

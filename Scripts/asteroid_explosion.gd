extends Node2D

@onready var sfx_explode: GPUParticles2D = get_node("explode")
@onready var sfx_sparks: GPUParticles2D = get_node("sparks")


func _ready():
	sfx_explode.emitting = true
	sfx_sparks.emitting = true

func _on_gpu_particles_2d_finished():
	call_deferred("queue_free")

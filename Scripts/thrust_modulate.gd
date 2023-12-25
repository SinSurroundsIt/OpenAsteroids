extends Sprite2D

@export var _modulate_scale: float = 0.8
var _mod_base: float = -1.00


func _process(delta):
	if visible:
		_mod_base += delta * 20
		if _mod_base > 1.00:
			_mod_base = -1.00
		var _sine_base: float = (sin(_mod_base) + 1.00) / 2
		var _modulate_value = _sine_base * _modulate_scale
		modulate.a = _modulate_value
		scale.y = 1 - (_sine_base * 0.25)

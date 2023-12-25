extends TextureRect

@onready var _shield_bar: ProgressBar = get_node("ShieldBar")

var _mod_base: float = -PI

var _b_pause_delay: bool = false


func _ready():
	Events.update_shield_strength.connect(_Set_Shield_Bar)
	Events.shield_timer_start.connect(_Start_Blinking)
	Events.shield_timer_stop.connect(_Stop_Blinking)


func _process(delta):
	if _b_pause_delay:
		_mod_base += delta * PI * 2
		if _mod_base > PI:
			_mod_base = -PI
		var _sine_base: float = (sin(_mod_base) / 3)
		var _modulate_value = _sine_base + 0.66
		modulate.a = _modulate_value
	else:
		if modulate.a != 1.0:
			modulate.a = 1.0

func _Set_Shield_Bar(max_shield: float, value: float):
	var temp_value: float = value / max_shield
	_shield_bar.value = temp_value * _shield_bar.max_value
	
func _Start_Blinking():
	_b_pause_delay = true
	
func _Stop_Blinking():
	_b_pause_delay = false

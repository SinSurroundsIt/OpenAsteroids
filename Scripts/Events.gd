# Event bus for distant nodes to communicate using signals.
extends Node

#Emitted when firing a laser.
signal fire_laser(source, position, velocity, rotation)
signal fire_laser_sound()

signal asteroid_destroyed(size: int, position: Vector2, velocity: Vector2)
signal asteroid_destroyed_sound()
signal asteroid_spawned()
signal get_asteroids()
signal send_asteroids(asteroids: Array)

signal game_state_changed(state: bool)

signal player_died()
signal new_lives(new_life_amount: int)
signal new_player_ship(ship: Ship)

#Used to update the current score of the round
signal update_score(new_score: int)

#Used to signal the level counter in interface.tscn
signal update_level(new_level: int)

#used to set ship to invulnerable and repel objects from origin
signal set_spawn_safety(b_safe: bool)

signal asteroid_explode(position: Vector2, velocity: Vector2 )
signal asteroid_laser_hit(pos: Vector2, normal: Vector2)

signal update_shield_strength(max: float, strength: float)
signal shield_timer_start()
signal shield_timer_stop()

signal shield_hit()
signal shield_down()

signal ship_explode(_pos: Vector2)

#used to send the number of asteroids to Asteroid Manager, and the level to the new level pop-up (TODO)
signal level_start(asteroids: int, level: int)


#Menu Signals
signal main_menu
signal controls_menu
signal credits_menu
signal settings_menu

#Score Signals
signal save_score

#Game start and end signals. Used to send the score to the high score autoload,
#and to tell the game manager to start a new round.
signal game_over(score: int)
signal new_game

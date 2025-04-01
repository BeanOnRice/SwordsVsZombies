extends Node2D

var character_chosen = null # allows dynamic character choosing based on what is chosen in character select
@export var slime_character: PackedScene # 0
# UPDATE _CHARACTER_CHOSEN_SETTER WHEN ADDING MORE CHARACTERS

#MOB SPAWNER

var map_chosen = null # same as character_chosen but for maps
@export var grass_map: PackedScene # 0
# UPDATE _CHARACTER_CHOSEN_SETTER WHEN ADDING MORE CHARACTERS

const HOW_MANY_NEED_TO_BE_READY: int = 1 #amount of things that need to be ready before game start
var ready_to_start: int = 0

func _process(delta: float) -> void:
	get_node("Camera2D").position = Vector2(PlayerStats.player_position)
	#make position clamp to edge of map########################
		#same for these: #I'll just put a collision on map edge for layers 1 and 2
		#player
		#zombieSpawner #this one still needs special solution
		#zombie


# called by main_menu in main menu mode and game over mode via signal to program_director
func _game_start() -> void:
	#Insert load screen##################################
	#queue free all children after camera2D####################
	# character load
	get_tree().set_pause(true)
	_character_chosen_setter()
	character_chosen.instantiate()
	add_child(character_chosen.instantiate())
	get_node("Swordsman").ready.connect(self._children_ready_signal_receiver)
	# map load
	_map_chosen_setter()
	map_chosen.instantiate()
	add_child(map_chosen.instantiate())
	get_node("Map").ready.connect(self._children_ready_signal_receiver)
	await ready_to_start == HOW_MANY_NEED_TO_BE_READY
	# zombie spawner load
	#zombiespawnerload#####################
	#Remove load screen##############################
	get_tree().set_pause(false)
	get_node("ScoreTimer").play()
	#make pause_menu unpausable

func _game_over() -> void:
	get_node("ScoreTimer").stop()
	#signal to program_director to bring out main menu set as game over mode
	#add score to wherever it belongs in the highscore linked list
	#make pause_menu pausable
	get_tree().set_pause(true)


# sets _game_start to instantiate chosen character (singleton because then we can enable character specific interactions more easily)
func _character_chosen_setter() -> void:
	var x = PlayerStats.player_character
	match x:
		0:
			character_chosen = slime_character
		_:
			print("ERROR: NO CHARACTER CHOSEN")

func _map_chosen_setter() -> void:
	var x = PlayerStats.map
	match x:
		0:
			map_chosen = grass_map
		_:
			print("ERROR: NO MAP CHOSEN")

#receives ready signal from children
func _children_ready_signal_receiver() -> void:
	ready_to_start += 1


# knocks back player based on signal received from enemy's handler
func _on_zombie_knock_this_player_back(dir: Vector2, knockback: int) -> void:
	get_node("Swordsman")._start_knock_back(dir, knockback)


func _on_score_timer_timeout() -> void:
	PlayerStats.score += 3

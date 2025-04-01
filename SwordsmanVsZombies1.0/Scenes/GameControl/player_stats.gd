extends Node

# set by Player class
var player_limit_break: float # _game_start() now can be affected by Buffs class
var player_character: int
var player_max_hp: int
var player_hp: float # _game_start() now can be affected by Zombie class
var player_movement_speed: int
var player_weapon_held: int
var player_weapon_dmg: float # set by weapons class on switch
var player_dmg_mod: float
var player_actual_dmg: float
var player_knockback: int
var player_range: float
var player_position: Vector2 = Vector2(0.0, 0.0)

var score: int # reset on game_start ######### added to on scoretimer reset ############ added to on monster death ######### added to on treasure box touch

var map: int # 0 == endless mode grass

var game_mode: int # 0 == endless mode, 1 == campaign

var spawn_timer: float #set by main menu, affects spawn rate of endless spawner

@export_group("HighScores", "highscore")
#set by GameDirector && sent to ProgramDirector
@export var highscore_svz: int #make into array of 10
#others set by MinigameDirector<x,y,z,etc etc>

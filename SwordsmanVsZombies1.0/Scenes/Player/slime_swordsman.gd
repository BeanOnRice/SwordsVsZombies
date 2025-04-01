@icon("res://Art/Player/Blue/Blue0.png")
class_name PlayerCharacter

extends CharacterBody2D
################################################DEPENDANCY LIST
#updates player_stats.gd(singleton)
	#same .gd can be used to fluidly change weapon, movement speed, actual dmg(dmg multiplier is here, ####### weapon base damage and weapon held lives in weapon class
################################################DEPENDANCY LIST

#local_stats (see CharacterStats in swordsman.gd)

#animation, walk & idle & attack

#launches and set player attack

#hitbox for being hit, touching loot, grabbing buffs

var current_weapon_scene = null
@export var fist: PackedScene
# UPDATE _WEAPON_SWITCH() WHEN ADDING NEW WEAPON

var past_dir: Vector2 #ONLY for facing left or right as default if not moving
var attacks_out: int = 0 #if more than 0 blocks movement. Goes up when a registered attack is used, down on return signal(registered: fist)

@export_group("CharacterStats", "local_")
@export var local_character = 0
@export var local_max_hp = 10
@export var local_hp = 10
@export var local_movement_speed = 400
@export var local_dmg_mod = 1
@export var local_range = 1
@export var local_limit_break = 0 #when more than 0 attacks ignore attacks_out (can be spammed)

@export var local_weapon_held = 0

func _ready() -> void: #sets character version
	position = Vector2(0, 0)
	get_node("AnimatedSprite2D").play()
	PlayerStats.player_character = local_character
	PlayerStats.player_max_hp = local_max_hp
	PlayerStats.player_hp = local_hp
	PlayerStats.player_movement_speed = local_movement_speed
	PlayerStats.player_dmg_mod = local_dmg_mod
	PlayerStats.player_range = local_range
	PlayerStats.player_limit_break = local_limit_break
	_weapon_switch(local_weapon_held)
	PlayerStats.score = 0

func _game_over() -> void:
	set_process(false)
	#death anim
	queue_free()

func _weapon_attack(vel: Vector2) -> void:  #attacks with current weapon #aims at currently faced vector
		var weapon = current_weapon_scene.instantiate()
		weapon.rotation = vel.angle()
		add_child(weapon)
	
func _weapon_switch(slot: int) -> void: #changes weapon to what the singleton says it is------sets base dmg of weapon damage
	attacks_out = 0
	match slot:
		_: #fist
			current_weapon_scene = fist




var being_knocked_back: bool = false
var direction_knockedback: Vector2
var distance_knocked_back_left: float

func _process(delta: float) -> void:
	if being_knocked_back == false:
		move_and_slide()
		#direction taker for player input
		velocity = Vector2(0.0, 0.0)
		if Input.is_action_pressed("ui_left"): 
			velocity.x += -1
			past_dir = Vector2(-1, 0)
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
			past_dir = Vector2(1, 0)
		if Input.is_action_pressed("ui_up"):
			velocity.y += -1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		
		#animation control
		if attacks_out < 1: #adds anim pause when an attack is out
			get_node("AnimatedSprite2D").play()
			if velocity.length() > 0: #changes anim based on moving or not
				get_node("AnimatedSprite2D").play("Move")
			else:
				get_node("AnimatedSprite2D").play("Idle")
		else:
			get_node("AnimatedSprite2D").play("Attack")

		#takes player input to do attack
		if Input.is_action_just_pressed("attack"):
			if local_weapon_held != PlayerStats.player_weapon_held: #checks if the loaded weapon is the same as the current weapon chosen(would be different if something changed the weapon held(like a buff) 
				_weapon_switch(PlayerStats.player_weapon_held)
			if PlayerStats.player_limit_break > 0 || attacks_out == 0: #if not limit break and an attack out, no attack done
				if velocity.length() > 0:
					_weapon_attack(velocity)
				else:
					_weapon_attack(past_dir)
				attacks_out += 1

			#movement
		if attacks_out < 1: #blocks movement when an attack is out
			position += velocity.normalized()*PlayerStats.player_movement_speed*delta
			
	else:
		_knocked_back(delta, direction_knockedback, distance_knocked_back_left)
	
		#checks if player is still alive
	if PlayerStats.player_hp == 0:
		_game_over()
	
	#updates player_position in player singleton
	PlayerStats.player_position = position




func _weapon_return() -> void:
	attacks_out -= 1

func _knocked_back(delta: float, dir: Vector2, distance: float) -> void: # runs knockback in process
	position += dir * lerpf(0.0, distance, 0.1) * delta * local_movement_speed
	distance_knocked_back_left -= lerpf(0.0, distance, 0.1)
	if distance_knocked_back_left <= 1:
		being_knocked_back = false

func _start_knock_back(direction: Vector2, distance: int) -> void: # registers the knockback
	being_knocked_back = true
	direction_knockedback = direction
	distance_knocked_back_left = distance

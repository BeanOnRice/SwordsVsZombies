@icon("res://Art/Player/Weapons/Fist.png")
class_name PlayerWeapon


extends StaticBody2D

#Starts small and grows in size during movement up until endpoint(enemy hit/range limit) 
var strike_end: bool = false
@export var speed: float = 4000.0

signal attack_done #####################KEY PART OF CLASS
@export_group ("WeaponStats", "weapon_")
@export var weapon_weapon_held = 0
@export var weapon_weapon_dmg = 7
@export var weapon_weapon_knockback = 300

const MAX_SIZE: float = 1.5  #1.5 (I might be lazy)

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	set_scale(Vector2(0.1, 0.1))
	$Area2D.monitoring = true
	$AttackSound.play()
	##########################################DEPENDENCY LIST
	speed = speed * PlayerStats.player_range #PlayerStats singleton
	PlayerStats.player_weapon_held = weapon_weapon_held
	PlayerStats.player_weapon_dmg = weapon_weapon_dmg
	PlayerStats.player_knockback = weapon_weapon_knockback
	PlayerStats.player_actual_dmg = PlayerStats.player_weapon_dmg * PlayerStats.player_dmg_mod

	#NEEDS PARENT
	##########################################
	attack_done.connect(get_node("..")._weapon_return) ############KEY PART OF CLASS (connects to Player class)


func _growth(delta: float, mod: int) -> void: #------------- #growth of fist
	var scaler: float =22.5*delta*mod
	set_scale(Vector2(scale.x+scaler, scale.y+scaler))


func _moving(delta:float, mod: int) -> void: #movement of fist(forward and back)
	move_local_x(delta*speed*mod, true)
	

func _process(delta: float) -> void:
	if strike_end:
		_growth(delta, -1)
		_moving(delta, -1)
		if scale <= Vector2(0.1, 0.1):
			set_process(false)
			hide()
			await get_tree().create_timer(0.1, false).timeout
			emit_signal("attack_done") #################KEY PART OF CLASS
			queue_free()
	else:
		_growth(delta, 1)
		_moving(delta, 1)
		if scale >= Vector2(MAX_SIZE, MAX_SIZE):
			$Area2D.monitoring = false
			strike_end = true


func _on_area_2d_body_entered(_body: Node2D) -> void:
		strike_end = true
		$Area2D.monitoring = false
		$HitSound.play()

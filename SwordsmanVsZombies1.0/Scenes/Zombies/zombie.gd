
class_name Zombie

extends CharacterBody2D
###########################################DEPENDANCY LIST
# PlayerStats.gd(singleton):
	# Player location
	# Player Knockback value
signal knock_this_player_back(dir: Vector2, knockback: int) # linked to game_director func _on_zombie_knock_this_player_back()
###########################################DEPENDANCY LIST
###################################################################CLASS VARS
@export_group("ZombieStats", "zombie_")
@export var zombie_hp: float = 10.0
@export var zombie_dmg: float = 5.0
@export var zombie_speed: float = 100.0
@export var zombie_knockback: int = 50
@export var zombie_score_value: int = 10
##################################################################

var player_found: bool
var zombie_stunned: int = 0 #when 0, not stunned #stun prevents attack anim && movement

# used in process for wandering
var wait_to_wander: bool = true #
var velocity_chosen: Vector2 = Vector2(0.0, 0.0)

var knocked_back_direction: Vector2
var knocked_back_distance_left: float
var knocked_back: bool = false

func _ready() -> void:
	knock_this_player_back.connect(get_node("..")._on_zombie_knock_this_player_back)
	get_node("AnimatedSprite2D").play("Spawn")
	zombie_stunned += 1
	if player_found == false:
		_wait_to_wander_reset()

func _process(delta: float) -> void:
	# checks if alive
	if zombie_hp <= 0:
		_death()
	# allows regular movement if no concussion, otherwise process sent into knockback setting
	if knocked_back == false:
		#movement
		if zombie_stunned == 0: #can we move?
			if player_found == true: #do we see player
				get_node("Chasing").play() #chase sound
				get_node("AnimatedSprite2D").play("Move")
				position += (PlayerStats.player_position - position).normalized() * zombie_speed * delta
			else:
				if wait_to_wander == false:
					if velocity_chosen == Vector2(0.0, 0.0):
						velocity_chosen = Vector2(randi_range(-10, 10), randi_range(-10, 10)).normalized()
						get_node("WanderTimeLeft").start(randi_range(3, 10))# range(little steps, adventure)
					position += velocity_chosen * zombie_speed * delta * 0.5
				else:
					get_node("AnimatedSprite2D").play("Idle")
	else:
		_knockedback(delta, knocked_back_direction, knocked_back_distance_left)

########################################CORE METHODS
#ivefallenandIcantgetup.exe #brief pause
func _im_hit(_Body: Node2D) -> void:
	get_node("Hurt").play() # sound
	_start_knock_back((PlayerStats.player_position - position).normalized(), PlayerStats.player_knockback)
	zombie_hp -= PlayerStats.player_actual_dmg
	get_node("AnimatedSprite2D").play("Hurt")
	zombie_stunned += 1

#starts knockback, changes process route to only register knockback (can still attack)
func _start_knock_back(dir: Vector2, distance: float) -> void:
	knocked_back = true
	knocked_back_direction = dir
	knocked_back_distance_left = distance

#knockedbackk
func _knockedback(delta: float, dir: Vector2, distance: float) -> void:
	position -= lerpf(0.0, distance, 0.1) * dir * delta * zombie_speed
	knocked_back_distance_left -= lerpf(0.0, distance, 0.1)
	if knocked_back_distance_left <= 1:
		knocked_back = false

# attacking #player health down #movement pause
func _attack(Body: Node2D) -> void: # attack player
	# checks to ensure not targeting itself
	if _is_this_a_zombie(Body) == false:
	# attack
		if zombie_stunned == 0:
			get_node("Attack").play() # sound
			get_node("AnimatedSprite2D").play("Attack")
			PlayerStats.player_hp -= zombie_dmg
			emit_signal("knock_this_player_back", ((PlayerStats.player_position - position).normalized()), zombie_knockback)
			zombie_stunned += 1
			await get_tree().create_timer(0.1, false).timeout

#death
func _death() -> void:
	set_process(false)
	get_node("Muerte").play() # sound
	get_node("AnimatedSprite2D").play("Dead") # anim
	#death anim
	PlayerStats.score += zombie_score_value
	queue_free()

# ends stun on animation end/change
func _anim_end_or_anim_change() -> void:
	if zombie_stunned > 0:
		zombie_stunned -= 1
		if zombie_stunned < 0:
			print("ERROR: zombie.zombie_stunned == ", zombie_stunned)

# waiting patiently to wander around
func _wait_to_wander_reset() -> void: #WanderTimeLeft is connected to this
	wait_to_wander = true
	get_node("WaitToWander").start(3.0)

# lets go(demon time)
func _lets_wander() -> void:
	velocity_chosen = Vector2(0.0, 0.0)
	wait_to_wander = false

#playerfound.exe
func _i_see_the_player(Body: Node2D) -> void:
	if _is_this_a_zombie(Body) == false:
		player_found = true
		get_node("WanderTimeLeft").stop()

#topa lol
func _i_lost_the_player(Body: Node2D) -> void:
	if _is_this_a_zombie(Body) == false:
		player_found = false
		_wait_to_wander_reset()

func _is_this_a_zombie(Body: Node2D) -> bool:
	for i in range (0, 6, 1):
		if (Body.to_string()[i] != self.to_string()[i]):
			return false
	return true
##############################CORE METHODS

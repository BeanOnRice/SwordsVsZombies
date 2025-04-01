class_name Map

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#4 sections of map ####################################1.Make background map separate scene 2.make zombie like player player_char thing, except different chars are chosen through (either spawner or singleton saying what zone we are in, maybe throw it into PlayerStats so Swordsman updates it when entering a new zone?)
#obstacles appear throughout map (type depend on section)
#lava & water pools generated first
	#then do obstacles checking for lava already there

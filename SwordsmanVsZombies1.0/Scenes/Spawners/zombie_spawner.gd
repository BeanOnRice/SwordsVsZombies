## Gives parent zombie children. Zombies allowed and their spawn chances set via _set_zombie_wishlist() <input dictionary must have stringname key matching zombie name and an int value over 0>
## Emits signal "spawn_complete" when done spawning.
class_name ZombieSpawner
extends Node2D

# catalogue of zombies, picked by setting zombie_catalogue_pick
## Holds pointer to chosen zombie
var zombie_catalogue_pick = null
@export var slime: PackedScene
#UPDATE _zombie_catalogue(pick: StringName) WHEN ADDING NEW ZOMBIES!!!!

## spawn process is complete
@warning_ignore("unused_signal") # meant for parent to connect to itself if it wants to know when spawn is done
signal spawn_complete
#how many spawns and time between them
## desired zombie type(lowercase) and its probability
var zombie_wishlist = {
	"slime": 60,
}

# initializes chosen zombie
func _spawn() -> void:
	_zombie_catalogue(_which_zombie(zombie_wishlist))
	var cur_spawning = zombie_catalogue_pick.instantiate()
	cur_spawning.global_position = self.get_global_position()
	get_node("..").add_child(cur_spawning, true)
	emit_signal("spawn_complete")

## Picks a zombie from catalogue using zombie wishlist (zombies requested and pick chance) and RETURNS name of chosen one
func _which_zombie(zombies_and_odds: Dictionary) -> StringName:
	var odds = PackedInt32Array(zombies_and_odds.values()) # to take up less space, may cause lag I do not know how expensivee this is processing wise
	var total_odds: int = 0
	var chosen: int = 0
	# adds up total_odds && preps odds[] for binary check
	for i in range(1, odds.size(), 1):
		odds[i] += odds[i-1]
	total_odds = odds[odds.size()-1]
	chosen = randi_range(1, total_odds)
	return zombies_and_odds.keys()[_which_zombie_binary_search(odds, chosen)]

## Part of _which_zombie(), just to keep things organized
func _which_zombie_binary_search(array: PackedInt32Array, target: int) -> int:
	var min_index = 0
	var max_index = array.size() - 1
	while ((1 <= target) && (target <= array[array.size()-1])):
		@warning_ignore("integer_division") # saves me using floori() lol (efficiency++++)
		var middle = (min_index+max_index)/2
		if (array[middle] == target) || (middle == max_index):
			return middle
		elif array[middle] > target: # target must be to the left!
			if (target > array[middle - 1]) || ((middle - 1) < 0):
				return middle
			max_index = middle
		elif array[middle] < target: # target must be to the right!
			if (target <= array[middle+1]):
				return (middle + 1)
			min_index = middle
	print("zombie_spawner.tscn _which_zombie_binary_search: target not in given array")
	return 1 # ERROR


## Sets the reference to input zombie
func _zombie_catalogue(pick: StringName) -> void:
	match pick:
		"slime":
			zombie_catalogue_pick = slime
		_:
			print("ERROR: ", self.to_string(), "_zombie_catalogue() INVALID ZOMBIE NAME ENTERED")

## Allows setting of zombies to spawn and their spawn odds (Overrides default wishlist when set!!!) ONLY PUT STRINGNAME KEYS AND POSITIVE VALUES
func _set_zombie_wishlist(wishlist: Dictionary) -> void:
	zombie_wishlist = wishlist

extends Node2D


var anitree 
var grav_rotation

func _ready():
	anitree = $AnimationTree.get("parameters/playback")
	#print($orbchangedirection.rotation_degrees)
	$arrow.rotation_degrees = $orbchangedirection.rotation_degrees
	grav_rotation = str(round($orbchangedirection.rotation_degrees))
	#print(get_node("hitbox").collision_layer)

func _on_hitbox_area_entered(area):
	anitree.travel("spawn")
	if get_node("hitbox").collision_layer == 8:
		GlobalScript.player_grav_index = GlobalScript.grav_dict[grav_rotation]
		
	elif get_node("hitbox").collision_layer == 16:
		GlobalScript.enemy_grav_index = GlobalScript.grav_dict[grav_rotation]
		GlobalScript.enemy_obey = true
		

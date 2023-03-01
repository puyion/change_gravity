extends Node2D


var anitree 
var grav_rotation

func _ready():
	anitree = $AnimationTree.get("parameters/playback")
	#print($orbchangedirection.rotation_degrees)
	$arrow.rotation_degrees = $orbchangedirection.rotation_degrees
	grav_rotation = str(round($orbchangedirection.rotation_degrees))


func _on_hitbox_area_entered(area):
	anitree.travel("spawn")
	GlobalScript.grav_index = GlobalScript.grav_dict[grav_rotation]

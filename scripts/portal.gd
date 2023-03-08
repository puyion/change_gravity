extends Node2D




func _ready():
	pass 




func _on_Area2D_area_entered(area):
	#print("level complete")
	GlobalScript.level += 1
	get_tree().change_scene(GlobalScript.level_list[GlobalScript.level])
	GlobalScript.player_grav_index = "down"
	GlobalScript.enemy_obey = false

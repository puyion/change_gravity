extends Camera2D




func _physics_process(delta):
						
	self.position = GlobalScript.player_coords
	$health.frame = GlobalScript.player_health
	$health.position = Vector2(get_viewport().size.x/1.8 - get_viewport().size.x, get_viewport().size.y/1.7 - get_viewport().size.y)
	
	$potion.position = Vector2($health.position.x + 40, $health.position.y + 20)
	$potion.frame = GlobalScript.potion_count

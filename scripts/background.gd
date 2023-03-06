extends ParallaxBackground



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	#$space/Sprite.rotation_degrees += 0.05
	$planet/Sprite.rotation_degrees += 0.02
	$planet2/Sprite.rotation_degrees += 0.02
	$planet3/Sprite.rotation_degrees += 0.1
	$planet4/Sprite.rotation_degrees += 0.1
	$gear/Sprite.rotation_degrees += 0.1
	$gear/Sprite2.rotation_degrees += -0.1

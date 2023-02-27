extends KinematicBody2D

#vector indicates direction, magnitude indicates strength
var gravity_vector = Vector2(0, 1)
var gravity_magnitude = 20


#player's speed, jump, and movement
var speed = 300
var jumpforce = 600
var velocity = Vector2(0,0)

#directional index
var index = 0


var grav_change = {"left":{"gravity_dir": Vector2(-1,0), #direction of gravity
							"index": -1, #for x and y switch (= abs(gravity vector.y) - 1)
							"speed_dir": 1, #change left and right
							"input": "grav_left", #button input
							"sprite_dir": Vector2(1,0) #sprite direction
							},
					"right":{"gravity_dir": Vector2(1,0),
							"index": -1,
							"speed_dir": -1,
							"input": "grav_right",
							"sprite_dir": Vector2(1,0)
							},
					"up":{"gravity_dir": Vector2(0,-1),
							"index": 0,
							"speed_dir": 1,
							"input": "grav_up",
							"sprite_dir": Vector2(0,1)
							},
					"down":{"gravity_dir": Vector2(0,1),
							"index": 0,
							"speed_dir": 1,
							"input": "grav_down",
							"sprite_dir": Vector2(1,0)
							}
					}

#index calls grav_change dictionary
var grav_change_index = "down"

var anitree

func _ready():
	anitree = $AnimationTree.get("parameters/playback")


func _physics_process(_delta):
	#velocity in both directions constantly changing
	velocity.x += gravity_magnitude * gravity_vector.x
	velocity.y += gravity_magnitude * gravity_vector.y
	
	
	#basic movement commands
	if Input.is_action_pressed("ui_left"):
		velocity[grav_change[grav_change_index]["index"]] = -speed * grav_change[grav_change_index]["speed_dir"]
		anitree.travel("walk")
		$Sprite.flip_h = grav_change[grav_change_index]["sprite_dir"][0]

	elif Input.is_action_pressed("ui_right"):
		velocity[grav_change[grav_change_index]["index"]] = speed * grav_change[grav_change_index]["speed_dir"]
		anitree.travel("walk")
		$Sprite.flip_h = grav_change[grav_change_index]["sprite_dir"][1]
		
	else:
		anitree.travel("idle")
	
	if Input.is_action_just_pressed("ui_up") and ((gravity_vector.x == 0 and is_on_floor()) or (gravity_vector.y == 0 and is_on_wall())):
		#the jump will be in the opposite of gravity direction
		velocity[grav_change[grav_change_index]["index"] + 1] = jumpforce * (-gravity_vector[grav_change[grav_change_index]["index"] + 1])	
	
	if (gravity_vector.x == 0 and not(is_on_floor())) or (gravity_vector.y == 0 and not(is_on_wall())):
		anitree.travel("jump")
	
	if Input.is_action_just_pressed("punch"):
		anitree.travel("punch")
		
	
	#basic movement 
	velocity = move_and_slide(velocity, Vector2(-1 * gravity_vector[grav_change[grav_change_index]["index"]], -1 * gravity_vector[grav_change[grav_change_index]["index"] + 1]))
	velocity[grav_change[grav_change_index]["index"]] = lerp(velocity[grav_change[grav_change_index]["index"]], 0, 0.2)
	
	#rotate character based on direction of gravity
	self.rotation_degrees = rad2deg(gravity_vector.angle()) - 90
	
	#change gravity based on wasd keys
	for i in grav_change:
		if Input.is_action_pressed(grav_change[i]["input"]):
			gravity_vector = grav_change[i]["gravity_dir"]
			grav_change_index = i
			velocity = Vector2.ZERO
	




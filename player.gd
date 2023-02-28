extends KinematicBody2D

#vector indicates direction, magnitude indicates strength
var gravity_vector = Vector2(0, 1)
var gravity_magnitude = 20


#player's speed, jump, movement, punch speed
var speed = 300
var jumpforce = 600
var velocity = Vector2(0,0)
var punch_speed = 3000

#directional index
var index = 0

#cardinal direction gravity
var grav_change = {"left":{"gravity_dir": Vector2(-1,0), #direction of gravity
							"index": -1, #for x and y switch (= abs(gravity vector.y) - 1)
							"speed_dir": 1, #change left and right
							"input": "grav_left", #button input
							"sprite_dir": Vector2(-0.5,0.5), #sprite direction
							"punch_dir": 1
							},
					"right":{"gravity_dir": Vector2(1,0),
							"index": -1,
							"speed_dir": -1,
							"input": "grav_right",
							"sprite_dir": Vector2(-0.5,0.5),
							"punch_dir": -1
							},
					"up":{"gravity_dir": Vector2(0,-1),
							"index": 0,
							"speed_dir": 1,
							"input": "grav_up",
							"sprite_dir": Vector2(0.5,-0.5),
							"punch_dir": -1
							},
					"down":{"gravity_dir": Vector2(0,1),
							"index": 0,
							"speed_dir": 1,
							"input": "grav_down",
							"sprite_dir": Vector2(-0.5,0.5),
							"punch_dir": 1
							}
					}

#index calls grav_change dictionary
var grav_change_index = "down"

var anitree

enum{
	MOVE,
	PUNCH,
	JUMP
}

var state = MOVE

func _ready():
	anitree = $AnimationTree.get("parameters/playback")


func _physics_process(_delta):
	#velocity in both directions constantly changing
	velocity.x += gravity_magnitude * gravity_vector.x
	velocity.y += gravity_magnitude * gravity_vector.y
	
	#basic movement 
	velocity = move_and_slide(velocity, Vector2(-1 * gravity_vector[grav_change[grav_change_index]["index"]], -1 * gravity_vector[grav_change[grav_change_index]["index"] + 1]))
	velocity[grav_change[grav_change_index]["index"]] = lerp(velocity[grav_change[grav_change_index]["index"]], 0, 0.2)
	
	#rotate character based on direction of gravity
	self.rotation_degrees = rad2deg(gravity_vector.angle()) - 90
	
	#change gravity based on wasd keys
	for i in grav_change:
		if Input.is_action_pressed(grav_change[i]["input"]):
			grav_change_index = i
			gravity_vector = grav_change[i]["gravity_dir"]
			velocity = Vector2.ZERO
			
	match state:
		MOVE:
			move_state()
		PUNCH:
			punch_state()
		JUMP:
			jump_state()
		


func move_state():
	#basic movement commands
	#checking if the character isn't punching because punch and walk speeds are different
	if Input.is_action_pressed("ui_left") and anitree.get_current_node() != "punch":
		velocity[grav_change[grav_change_index]["index"]] = -speed * grav_change[grav_change_index]["speed_dir"]
		anitree.travel("walk")
		$Sprite.scale.x = grav_change[grav_change_index]["sprite_dir"][0]
		
	elif Input.is_action_pressed("ui_right") and anitree.get_current_node() != "punch":
		velocity[grav_change[grav_change_index]["index"]] = speed * grav_change[grav_change_index]["speed_dir"]
		anitree.travel("walk")
		$Sprite.scale.x = grav_change[grav_change_index]["sprite_dir"][1]
		
	else:
		anitree.travel("idle")
	
	#run
	if Input.is_action_pressed("shift") and ((gravity_vector.x == 0 and is_on_floor()) or (gravity_vector.y == 0 and is_on_wall())):
		speed = 450
	else:
		speed = lerp(speed, 300, 0.2)
	
	#in air
	if (gravity_vector.x == 0 and not(is_on_floor())) or (gravity_vector.y == 0 and not(is_on_wall())):
		anitree.travel("jump")
	
	
	#switching to jump
	if Input.is_action_just_pressed("ui_up") and ((gravity_vector.x == 0 and is_on_floor()) or (gravity_vector.y == 0 and is_on_wall())):
		state = JUMP
		
	#switching to punch
	if Input.is_action_just_pressed("punch") and anitree.get_current_node() != "punch":
		state = PUNCH
		
	
func punch_state():
	anitree.travel("punch")
	
	if (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
		velocity[grav_change[grav_change_index]["index"]] = punch_speed * 2 * $Sprite.scale.x * grav_change[grav_change_index]["punch_dir"]
		state = MOVE
	else:
		velocity[grav_change[grav_change_index]["index"]] = 0
		state = MOVE
		
		
func jump_state():
	#the jump will be in the opposite of gravity direction
	velocity[grav_change[grav_change_index]["index"] + 1] = jumpforce * (-gravity_vector[grav_change[grav_change_index]["index"] + 1])	
	
	#checks if player is punching, otherwise, just switch to move
	if Input.is_action_just_pressed("punch"):
		state = PUNCH
	state = MOVE
	
	
func _on_punchhit_area_entered(area):
	print("hit")



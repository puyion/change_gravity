extends KinematicBody2D

#vector indicates direction, magnitude indicates strength
var gravity_vector = Vector2()
var gravity_magnitude = 20


#player's speed, jump, movement, punch speed, speed off wall jump
var speed = 300
var jumpforce = 600
var velocity = Vector2(0,0)
var punch_speed = 3000
var wall_jump_speed = 2000


#directional index
var index = 0

#cardinal direction gravity
var grav_change = {"left":{"gravity_dir": Vector2(-1,0), #direction of gravity
							"index": -1, #for x and y switch (= abs(gravity vector.y) - 1)
							"speed_dir": 1, #change left and right
							"input": "grav_left", #button input
							"sprite_dir": Vector2(-0.5,0.5), #sprite direction
							"punch_dir": 1,
							"wall_dir": 1
							},
					"right":{"gravity_dir": Vector2(1,0),
							"index": -1,
							"speed_dir": -1,
							"input": "grav_right",
							"sprite_dir": Vector2(-0.5,0.5),
							"punch_dir": -1,
							"wall_dir": 1
							},
					"up":{"gravity_dir": Vector2(0,-1),
							"index": 0,
							"speed_dir": 1,
							"input": "grav_up",
							"sprite_dir": Vector2(0.5,-0.5),
							"punch_dir": -1,
							"wall_dir": -1
							},
					"down":{"gravity_dir": Vector2(0,1),
							"index": 0,
							"speed_dir": 1,
							"input": "grav_down",
							"sprite_dir": Vector2(-0.5,0.5),
							"punch_dir": 1,
							"wall_dir": 1
							}
					}

#index calls grav_change dictionary
var grav_change_index

var anitree

enum{
	MOVE,
	PUNCH,
	JUMP,
	WALL,
	HURT
}

var state = MOVE

var wall_dir = 1
var last_wall_dir = 0

var health = 5

func _ready():
	anitree = $AnimationTree.get("parameters/playback")


func _physics_process(_delta):
	grav_change_index = GlobalScript.player_grav_index
	GlobalScript.player_health = health
	GlobalScript.player_coords = self.position
	
	#velocity in both directions constantly changing
	velocity.x += gravity_magnitude * gravity_vector.x
	velocity.y += gravity_magnitude * gravity_vector.y
	
	#basic movement 
	velocity = move_and_slide(velocity, Vector2(-1 * gravity_vector[grav_change[grav_change_index]["index"]], -1 * gravity_vector[grav_change[grav_change_index]["index"] + 1]))
	velocity[grav_change[grav_change_index]["index"]] = lerp(velocity[grav_change[grav_change_index]["index"]], 0, 0.2)
	
	#rotate character based on direction of gravity
	self.rotation_degrees = rad2deg(gravity_vector.angle()) - 90
	$wallchecker.rotation_degrees = 90 * -$Sprite.scale.x * 2 * wall_dir

	#change gravity based on wasd keys
#	for i in grav_change:
#		if Input.is_action_pressed(grav_change[i]["input"]):
#			grav_change_index = i
#			gravity_vector = grav_change[i]["gravity_dir"]
#			velocity = Vector2.ZERO
			
	for i in grav_change:
		if i == grav_change_index:
			gravity_vector = grav_change[i]["gravity_dir"]
	
	match state:
		MOVE:
			move_state()
		PUNCH:
			punch_state()
		JUMP:
			jump_state()
		WALL:
			wall_state()
		HURT:
			hurt_state()
	

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
		
	#on ground (for changes during move state)
	if (gravity_vector.x == 0 and is_on_floor()) or (gravity_vector.y == 0 and is_on_wall()):
		last_wall_dir = 0
		
	#in air
	if (gravity_vector.x == 0 and not(is_on_floor())) or (gravity_vector.y == 0 and not(is_on_wall())):
		anitree.travel("jump")
		#switching to wall, checks your going into wall -> so you can still jump against a wall and not be wall sliding
		if $wallchecker.is_colliding() and ((Input.is_action_pressed("ui_left") and $wallchecker.rotation_degrees == 90 * grav_change[grav_change_index]["wall_dir"]) or (Input.is_action_pressed("ui_right") and $wallchecker.rotation_degrees == -90 * grav_change[grav_change_index]["wall_dir"])):
			wall_dir = -1
			$Sprite.scale.x *= -1
			state = WALL
	
	#switching to jump
	if Input.is_action_just_pressed("ui_up") and ((gravity_vector.x == 0 and is_on_floor()) or (gravity_vector.y == 0 and is_on_wall())):
		state = JUMP
		
	#switching to punch
	if Input.is_action_just_pressed("punch") and anitree.get_current_node() != "punch" and anitree.get_current_node() != "hurt":
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
	anitree.travel("jump")
	#the jump will be in the opposite of gravity direction
	velocity[grav_change[grav_change_index]["index"] + 1] = jumpforce * (-gravity_vector[grav_change[grav_change_index]["index"] + 1])	
	
	#checks if player is punching, otherwise, just switch to move
	if Input.is_action_just_pressed("punch"):
		state = PUNCH
	state = MOVE

func wall_state():
	anitree.travel("wallslide")
	velocity[grav_change[grav_change_index]["index"] + 1] = 0.2 * jumpforce * (gravity_vector[grav_change[grav_change_index]["index"] + 1])
	#checks first to see if the player has already jumped in that direction
	if last_wall_dir != $Sprite.scale.x:
		if Input.is_action_just_pressed("ui_right") and ($Sprite.scale.x * grav_change[grav_change_index]["wall_dir"]) > 0 and not(Input.is_action_pressed("ui_left")):
			velocity[grav_change[grav_change_index]["index"]] = wall_jump_speed
			wall_dir = 1
			last_wall_dir = $Sprite.scale.x
			state = JUMP
		
		if Input.is_action_just_pressed("ui_left") and ($Sprite.scale.x * grav_change[grav_change_index]["wall_dir"]) < 0 and not(Input.is_action_pressed("ui_right")):
			velocity[grav_change[grav_change_index]["index"]] = wall_jump_speed
			wall_dir = 1
			last_wall_dir = $Sprite.scale.x
			state = JUMP
	else:
		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
			wall_dir = 1
			state = MOVE
	
	if not($wallchecker.is_colliding()):
		wall_dir = 1
		anitree.travel("jump")
		state = MOVE
	
	if (gravity_vector.x == 0 and is_on_floor()) or (gravity_vector.y == 0 and is_on_wall()):
		last_wall_dir = 0
		wall_dir = 1
		state = MOVE

	
func _on_hitbox_area_entered(area):
	if area.collision_layer == 128:
		health -= 1
		
		GlobalScript.player_coords = self.position
		if GlobalScript.enemy_coords[grav_change[grav_change_index]["index"]] > GlobalScript.player_coords[grav_change[grav_change_index]["index"]]:
			velocity[grav_change[grav_change_index]["index"]] += 5 * -speed * grav_change[grav_change_index]["speed_dir"]
		if GlobalScript.enemy_coords[grav_change[grav_change_index]["index"]] < GlobalScript.player_coords[grav_change[grav_change_index]["index"]]:
			velocity[grav_change[grav_change_index]["index"]] += 5 * speed * grav_change[grav_change_index]["speed_dir"]
		velocity[grav_change[grav_change_index]["index"] + 1] = 0.7 * jumpforce * (-gravity_vector[grav_change[grav_change_index]["index"] + 1])
		state = HURT
		
func hurt_state():
	anitree.travel("hurt")
	
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	Input.action_release("punch")
	
	set_modulate(Color(0.3,0.3,0.3,0.3))
	yield(get_tree().create_timer(0.03), "timeout")
	set_modulate(Color(1,1,1,1))
	yield(get_tree().create_timer(0.03), "timeout")
	set_modulate(Color(0.3,0.3,0.3,0.3))
	yield(get_tree().create_timer(0.03), "timeout")
	set_modulate(Color(1,1,1,1))
	
	state = MOVE



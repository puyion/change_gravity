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
var grav_direction = {"grav_left": Vector2(-1,0),
					"grav_right": Vector2(1,0),
					"grav_up": Vector2(0,-1),
					"grav_down": Vector2(0,1)}

func _ready():
	pass


func _physics_process(_delta):
	#velocity in both directions constantly changing
	velocity.x += gravity_magnitude * gravity_vector.x
	velocity.y += gravity_magnitude * gravity_vector.y
	
	index = abs(gravity_vector.y) - 1
	
	#basic movement commands
	if Input.is_action_pressed("ui_right"):
		velocity[index] = speed
	if Input.is_action_pressed("ui_left"):
		velocity[index] = -speed
	if Input.is_action_just_pressed("ui_up") and ((gravity_vector.x == 0 and is_on_floor()) or (gravity_vector.y == 0 and is_on_wall())):
		#the jump will be in the opposite of gravity direction
		velocity[index + 1] = jumpforce * (-gravity_vector[index + 1])	
	
	#rotate character based on direction of gravity
	self.rotation_degrees = rad2deg(gravity_vector.angle()) - 90
	
	#basic movement 
	move_and_slide(velocity, Vector2(-1 * gravity_vector[index], -1 * gravity_vector[index + 1]))
	velocity[index] = lerp(velocity[index], 0, 0.2)

	#change gravity based on wasd keys
	for i in grav_direction:
		if Input.is_action_pressed(i):
			gravity_vector = grav_direction[i]
			velocity = Vector2.ZERO
			
	"""set a variable to check gravity direction
		change speed based on direction
		this will also help for the actual sprite direction"""
	



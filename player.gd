extends KinematicBody2D

#vector indicates direction, magnitude indicates strength
var gravity_vector = Vector2(0, 1)
var gravity_magnitude = 20


#player's speed, jump, and movement
var speed = 300
var jumpforce = 600
var velocity = Vector2(0,0)


func _ready():
	pass


func _physics_process(delta):
	#velocity in both directions constantly changing
	velocity.x += gravity_magnitude * gravity_vector.x
	velocity.y += gravity_magnitude * gravity_vector.y
	
	#basic movement commands
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		#the jump will be in the opposite of gravity direction
		velocity.y = jumpforce * (-gravity_vector.y)
	
	#change gravity
	if Input.is_action_just_pressed("ui_down"):
		gravity_vector.y *= -1
		velocity = Vector2.ZERO
		$Sprite.flip_v = gravity_vector.y-1

	#print(velocity.y)
	
	#basic movement (may have to create two functions for x and y direction)
	move_and_slide(velocity, Vector2(-1 * gravity_vector.x, -1 * gravity_vector.y))
	velocity.x = lerp(velocity.x, 0, 0.2)





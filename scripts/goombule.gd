extends KinematicBody2D

var gravity_vector = Vector2()
var gravity_magnitude = 20
var speed = 100
var velocity = Vector2(0,0)

var index = 0

var grav_change = {"left":{"gravity_dir": Vector2(-1,0), #direction of gravity
							"index": -1, #for x and y switch (= abs(gravity vector.y) - 1)
							"speed": 1,
							"set_dir": 1,
							"hit_dir": -1
							},
					"right":{"gravity_dir": Vector2(1,0),
							"index": -1,
							"speed": -1,
							"set_dir": 1,
							"hit_dir": 1
							},
					"up":{"gravity_dir": Vector2(0,-1),
							"index": 0,
							"speed": -1,
							"set_dir": -1,
							"hit_dir": -1
							},
					"down":{"gravity_dir": Vector2(0,1),
							"index": 0,
							"speed": 1,
							"set_dir": 1,
							"hit_dir": -1
							}
					}
					
enum{
	IDLE,
	MOVE,
	ATTACK,
	HURT,
	DEAD
}

var grav_change_index

var anitree
var state = IDLE
var health = 1

func _ready():
	anitree = $AnimationTree.get("parameters/playback")

func _physics_process(delta):
	grav_change_index = GlobalScript.enemy_grav_index
	GlobalScript.enemy_coords = self.position
	
	#velocity in both directions constantly changing
	velocity.x += gravity_magnitude * gravity_vector.x
	velocity.y += gravity_magnitude * gravity_vector.y
	
	#basic movement 
	velocity = move_and_slide(velocity, Vector2(-1 * gravity_vector[grav_change[grav_change_index]["index"]], -1 * gravity_vector[grav_change[grav_change_index]["index"] + 1]))
	velocity[grav_change[grav_change_index]["index"]] = lerp(velocity[grav_change[grav_change_index]["index"]], 0, 0.2)
	
	#rotate character based on direction of gravity
	self.rotation_degrees = rad2deg(gravity_vector.angle()) - 90
	

	for i in grav_change:
		if i == grav_change_index:
			gravity_vector = grav_change[i]["gravity_dir"]

	match state:
		IDLE:
			idle_state()
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		HURT:
			hurt_state()
		DEAD:
			dead_state()

func idle_state():
	anitree.travel("idle")
	velocity[grav_change[grav_change_index]["index"]] = 0
	if anitree.get_current_node() == "walk":
		state = MOVE
	
func move_state():
	anitree.travel("walk")
	velocity[grav_change[grav_change_index]["index"]] = speed * ($Sprite.scale.x/3) * grav_change[grav_change_index]["speed"]
	if $Sprite/wallchecker.is_colliding():
		$Sprite.scale.x *= -1
	if anitree.get_current_node() == "idle":
		state = IDLE
	
func attack_state():
	anitree.travel("attack")
	velocity[grav_change[grav_change_index]["index"]] = 2 * speed * ($Sprite.scale.x/3) * grav_change[grav_change_index]["speed"]
	if $Sprite/wallchecker.is_colliding():
		$Sprite.scale.x *= -1
	if anitree.get_current_node() == "idle":
		state = IDLE
		
	
func hurt_state():
	anitree.travel("hurt")
	state = IDLE

func dead_state():
	pass

func _on_hitbox_area_entered(area):
	if area.collision_layer == 2:
		health -= 1
		if GlobalScript.enemy_coords[grav_change[grav_change_index]["index"]] > GlobalScript.player_coords[grav_change[grav_change_index]["index"]]:
			velocity[grav_change[grav_change_index]["index"]] += 8 * -300 * grav_change[grav_change_index]["hit_dir"]
		if GlobalScript.enemy_coords[grav_change[grav_change_index]["index"]] < GlobalScript.player_coords[grav_change[grav_change_index]["index"]]:
			velocity[grav_change[grav_change_index]["index"]] += 8 * 300 * grav_change[grav_change_index]["hit_dir"]
		velocity[grav_change[grav_change_index]["index"] + 1] = 0.7 * 300 * (-gravity_vector[grav_change[grav_change_index]["index"] + 1])
#		if health <= 0:
#			state = DEAD
#		else:
#			state = HURT
		state = HURT
		
func _on_playerdetect_area_entered(area):
	state = ATTACK

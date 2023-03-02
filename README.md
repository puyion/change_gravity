# change_gravity
changing direction of gravity of player in godot 2d

NOTES:

-created small sample level using a tileset found off google

-for the "3d" effect, it's simply the parallax backgrounds layered at different sizes and moving at different relative motions

-the main tilemap is for the actual collisions but it is hidden because the parallax backgrounds are always at the back of every object

-added orbs that change gravity if you punch them

-added orb that changes gravity of just the enemy

-enemy can hurt you and you can punch it

-added health bar

CONTROLS:

left, right = move

up = jump

spacebar = punch

(left or right) + spacebar = punch dash

shift = dash

left or right against wall = wall slide

left or right away from wall = wall jump

NEXT STEPS:

-enemy is currently invincible when attacking, may need to change animation state machine to blend machine

-create levels

-possible slide

-possible planets with own gravity


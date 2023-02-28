# change_gravity
changing direction of gravity of player in godot 2d

NOTES:

-created small sample level using a tileset found off google

-for the "3d" effect, it's simply the parallax backgrounds layered at different sizes and moving at different relative motions

-the main tilemap is for the actual collisions but it is hidden because the parallax backgrounds are always at the back of every object

-created a enum state function for code which fixed the animation issue and added some bonus controls

-wall jump added, only works in one direction

CONTROLS:

left, right = move

up = jump

wasd keys = change gravity in direction of key

spacebar = punch

(left or right) + spacebar = punch dash

shift = dash

left or right on wall = wall jump

NEXT STEPS:

-change way gravity changes

-create levels

-add wall jump in all directions

-possible slide

-possible planets with own gravity


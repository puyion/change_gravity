extends Node

var player_grav_index = "down"
var enemy_grav_index = "down"

var grav_dict = {"90": "left",
				"270": "right",
				"180": "up",
				"0": "down"}

var gamemode
var level

var player_coords = Vector2()
var enemy_coords = Vector2()

var player_health = 5
var potion_count = 0

extends Node

var username = ""
var color = Color.green
var points = 0
var net_id = 1
var player_info = {}
var id_list = []
var player_list = {}
var player_count = 1
var team = 1
var starting_item = "Buzz Saw"


func set_info():
#	if starting_item == "Sparkle Gun":
#		starting_item = Globals.sparkle_gun
#	elif starting_item == "Blooper":
#		starting_item = Globals.blooper
#	else:
#		starting_item = Globals.pea_shooter
	
	player_info["username"] = username
	player_info["color"] = color
	player_info["points"] = points
	player_info["starting_item"] = starting_item.to_lower()
	player_list[1] = player_info


func set_ids():
	if !Globals.single_player:
		net_id = get_tree().get_network_unique_id()
		id_list = get_tree().get_network_connected_peers()

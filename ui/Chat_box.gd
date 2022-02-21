extends Control

var player_name = ""

func _ready():
	$Send_button/Text_to_send.grab_focus()


func _on_Send_button_pressed():
	var message = player_name + ": " + $Send_button/Text_to_send.text
	
	if get_tree().has_network_peer():
		rpc("update_chat", message)
	
#	#$Chat_list.add_item(message)
#	update_chat(message)
#
#	for p in get_tree().get_network_connected_peers():
#		print(p)
#		rpc_id(p, "update_chat", message)
		
	$Send_button/Text_to_send.clear()
	$Send_button/Text_to_send.grab_focus()
		
sync func update_chat(message):
	print("message recieved " + message)
	$Chat_list.add_item(message)
	

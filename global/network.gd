extends Node

const DEFAULT_PORT = 6900
const MAX_CLIENTS = 5

var server = null
var client = null

var ip_address = "192.168.1.7"
var public_ip = ""
var server_list = {"server_list":{}}

var server_request = HTTPRequest.new()
var server_url = "https://api.jsonbin.io/v3/b/61d11e41c912fe67c50ca37b"
var read_headers = ["X-Master-Key:", "$2b$10$XwfPVkqax5jvANipkdFEfur7c9YjgTD4paNz7IaI5zviPyRt1yrOm"]
var write_headers = ["X-Master-Key:", "$2b$10$XwfPVkqax5jvANipkdFEfur7c9YjgTD4paNz7IaI5zviPyRt1yrOm", "Content-Type: application/json", "X-Bin_Versioning: false"]

func _ready():
	#add_child(server_request)
	
	#server_request.connect("request_completed", self, "_http_request_completed")
	#server_request.request("https://api.myip.com")
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self, "_player_joined")
	get_tree().connect("connection_failed", self, "_connection_failed")


func _http_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	print(response.result)
	if response.result.has("cc"):
		print("found ip")
		public_ip = response.result["ip"]
		print(public_ip)
	elif response.result.has("record"):
		if response.result.has("record"):#.has("server_list"):
			print("getting server list")
			#var list = JSON.parse(body.get_string_from_utf8())
			server_list = response.result.record
			print("server list: " + str(server_list))
#		elif response.result.has("hostname"):
#			print(response.result.record)
	
func create_server():
#	var upnp = UPNP.new()
	print("Starting server")
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
#	upnp.discover(2000, 2, "InternetGatewayDevice")
#	upnp.add_port_mapping(6900, 6900)
	get_tree().set_network_peer(server)

func join_server():
	print("joining: " + ip_address)
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func _connected_to_server():
	#print("connected to server!")	
	pass

func _server_disconnected():
	print("disconnected from server")

func _player_joined(id):
	#print("player  id#: " +str(id) + "  connected")
	pass
	
func _connection_failed():
	print("failed connection")


func get_server_list():
	server_request.request(server_url + "/latest", read_headers)

func add_self_as_server(_dict:Dictionary):
	Network.get_server_list()
	print("updating list....")
	yield(get_tree().create_timer(1.5),"timeout")
	print(server_list)
	print("...adding self to server list...")
	server_list[_dict["hostname"]] = _dict
	server_request.request(server_url, write_headers, true, HTTPClient.METHOD_PUT, JSON.print(server_list))

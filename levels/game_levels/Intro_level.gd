extends Spatial

var bullet_num = 0

func _ready():
	
	var reuse = false
	for e in Entities.mobs.get_children():
		if e.is_in_group("Player"):
			reuse = true
	if reuse == false:
		instance_player(1)
	else:
		for p in Entities.mobs.get_children():
			if p.is_in_group("Player"):
				p.global_transform.origin = get_node("Spawns/" + str(Globals.current_level)).global_transform.origin
		
	Globals.connect("player_shot", self, "_player_shot")
	Globals.connect("remove_bullet", self, "_remove_bullet")
	Globals.connect("respawn_player", self, "_respawn_player")
	Globals.connect("remove_enemy", self, "remove_enemy")
	
	Globals.current_level = 0

func instance_players():
	for id in Players.player_list:
		instance_player(id)

	
func instance_player(id):
	print("creating player  " +str(id))
	var p = Globals.player.instance()
	Entities.mobs.add_child(p)
	p.initialize(id)
	p.global_transform = get_node("Spawns/0").global_transform

func _respawn_player(player):
	print("you have died")
	var p = Entities.mobs.get_node(player)
	p.die()
	#p.hide()
	p.global_transform = get_node("Spawns/0").global_transform
	yield(get_tree().create_timer(1),"timeout")
	#p.show()
	

func remove_enemy(enemy):
	if Entities.mobs.has_node(enemy):
		Entities.mobs.get_node(enemy).queue_free()
		print("enemy " + enemy +" removed")
	pass

func _remove_bullet(bullet):
	#rpc("_remove_bullet_remote", bullet)
	if Entities.bullets.has_node(bullet):
		Entities.bullets.get_node(bullet).queue_free()
		#print(bullet +" removed")

remote func _remove_bullet_remote(bullet):
	if Entities.bullets.has_node(bullet):
		Entities.bullets.get_node(bullet).queue_free()
		#print(bullet +" removed")	

func _on_AudioStreamPlayer3D_finished():
	$AudioStreamPlayer3D.play()


func _on_Scene_trigger_body_entered(body):
	if body.is_in_group("Player"):
		for e in Entities.mobs.get_children():
			if e.is_in_group("Enemy"):
				e.queue_free()
		get_tree().change_scene("res://levels/game_levels/hub_level.tscn")

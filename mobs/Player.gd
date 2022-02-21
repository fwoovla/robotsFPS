extends KinematicBody

export(NodePath) onready var turret = get_node(turret) as Spatial

var velocity = Vector3.ZERO
var speed = 15.0
var ground_acc = 15.0
var air_acc = 2
var jump_power = 20
var jumping = false
var health = 100
var max_health = 125
var guns = []
var gun_index = 0
var items = []
var current_gun = null
var bullet_num = 0



func _ready():

	Globals.connect("bullet_hit", self, "_bullet_hit")

func initialize(id):
	print("pltized")
	name = str(id)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#$Turret/Camera.current = true
	#$network_timer.start()
	$health.show()
	$crosshair.show()
	$hit_label.show()
	$ammo.show()
	$robot_1.visible = false

	
	if Players.player_list[id]["starting_item"] == "pea shooter":
		guns.append(Globals.pea_shooter.instance())
	elif Players.player_list[id]["starting_item"] == "blooper":
		guns.append(Globals.blooper.instance())
	elif Players.player_list[id]["starting_item"] == "sparkle gun":
		guns.append(Globals.sparkle_gun.instance())		
	elif Players.player_list[id]["starting_item"] == "buzz saw":
		guns.append(Globals.buzz_saw.instance())		
				
	current_gun = guns[gun_index]
	$Turret.add_child(current_gun)
		
func _process(delta):
	$health.text = " "
	$health.text = str(health)
	$team.text = str(Players.team)
	$ammo.text = str(current_gun.ammo_count)

		
func _physics_process(delta):
	aim_crosshair()
	var movement = _get_movement()
	var _acc = 0
	
	if is_on_floor():
		_acc = ground_acc
	else:
		_acc = air_acc
		
	velocity.x = lerp(velocity.x, movement.x * speed, _acc * delta)
	velocity.z = lerp(velocity.z, movement.z * speed, _acc * delta)
	#print(is_on_floor())

	if !is_on_floor():
		velocity.y += Globals.gravity * delta
	elif is_on_floor() and !jumping:
		#print("setting")
		velocity.y = 0

	if !$Tween.is_active():
		pass

	var snap = -get_floor_normal()
	if jumping:
		snap = Vector3.ZERO
	velocity.y = move_and_slide_with_snap(velocity, snap, Vector3.UP, true).y
			

func _unhandled_input(event):

	if event is InputEventMouseMotion:
		_handle_camera_rotation(event)
		
func _handle_camera_rotation(event):
	rotate_y(deg2rad(-event.relative.x) * Globals.camera_sensitivity)
	$Turret.rotate_x(deg2rad(-event.relative.y) * Globals.camera_sensitivity)
	$Turret.rotation.x = clamp($Turret.rotation.x, deg2rad(Globals.MIN_CAMERA_ANGLE), deg2rad(Globals.MAX_CAMERA_ANGLE))

func _get_movement():
	var dir = Vector3.DOWN
	
	jumping = false
	
	if Input.is_action_pressed("forward"):

		dir -= transform.basis.z
	if Input.is_action_pressed("backward"):

		dir += transform.basis.z
	if Input.is_action_pressed("left"):

		dir -= transform.basis.x
	if Input.is_action_pressed("right"):

		dir += transform.basis.x		

	if Input.is_action_just_pressed("jump") and is_on_floor():
		$sounds/jump.play()
		velocity.y = jump_power
		jumping = true
		
	if Input.is_action_just_pressed("shoot") or Input.is_action_pressed("shoot"):
		current_gun.shoot(name, bullet_num)
		bullet_num +=1
	
	if Input.is_action_just_pressed("right_mouse"):
		$Tween.interpolate_property($Turret/Camera, "fov", 70, 30, .1)
		$Tween.start()
	if Input.is_action_just_released("right_mouse"):
		$Tween.interpolate_property($Turret/Camera, "fov", $Turret/Camera.fov, 70, .1)
		$Tween.start()
	
	if Input.is_action_just_pressed("tab") or Input.is_action_just_pressed("ui_cancel"):
		show_menus()
		
	if Input.is_action_just_pressed("next_item") or Input.is_action_just_pressed("wheel_up"):
		$sounds/wepon_switch.play()
		next_gun()
		
	if Input.is_action_just_pressed("action"):
		do_action()
	
	return dir.normalized()

func next_gun():
	$Turret.remove_child(current_gun)
	gun_index +=1
	if gun_index > guns.size() -1:
		gun_index = 0
	current_gun = guns[gun_index]
	$Turret.add_child(current_gun)


func take_damage(dmg, bullet_owner):
	$Turret/Camera/AnimationPlayer.play("take_hit")
	$damage/AnimationPlayer.stop(true)
	$damage/AnimationPlayer.play("damage")
	$sounds/hit_sound.play()
	health -= dmg
	if health <=0:
		health = 100
		$die_panel/Label.text = " You were dispatched by " + str(bullet_owner)
		Globals.emit_signal("respawn_player", name)
	
func _bullet_hit(damage, bullet_owner):

	if bullet_owner == name:
		$hit_label.modulate = Color.white
		$hit_label.text = str(damage)
		$hit_label.show()
		$hit_label/Tween.interpolate_property($hit_label, "modulate", $hit_label.modulate, Color.transparent, .5)
		$hit_label/Tween.start()	

func get_health(health_val):
	$health_effect/AnimationPlayer.play("pick_up")
	health +=health_val
	if health > max_health:
		health = max_health

func get_item(item):
	$pickup_effect/AnimationPlayer.play("pick_up")
	var gun = item.instance()
	#print("new gun name" + gun.name)
	var has_item = false 
	for g in guns:
		if g.name == gun.name:
			has_item = true
			g.ammo_count += gun.ammo_count
			if g.ammo_count > g.max_ammo:
				g.ammo_count = g.max_ammo
	if !has_item:
		guns.append(gun)
	#print(guns.size())

remote func update_score(player, score):
	Players.player_list[int(player)]["points"] = score
	Globals.emit_signal("new_score", player, Players.player_list[int(player)]["points"])
	#print(Players.player_list)

func _on_Back_button_pressed():
	for e in Entities.mobs.get_children():
		e.queue_free()
	get_tree().change_scene("res://ui/Lobby.tscn")

func aim_crosshair():
	var point = $Turret/Camera.unproject_position($Turret/targeting_ray.get_collision_point())
	$crosshair.set_global_position(point)
	#also get info on object
	if $Turret/targeting_ray.is_colliding():
		var c = $Turret/targeting_ray.get_collider()
		
		if c.is_in_group("Eye") and c.visible and global_transform.origin.distance_to($Turret/targeting_ray.get_collision_point()) < 5:
			$info.text = "Broken Bob Eye"
			$info.visible = true
			
		elif c.is_in_group("Keycard") and c.visible and global_transform.origin.distance_to($Turret/targeting_ray.get_collision_point()) < 5:
			$info.text = "Keycard"
			$info.visible = true
			
		elif c.is_in_group("Keypad") and c.visible and global_transform.origin.distance_to($Turret/targeting_ray.get_collision_point()) < 5:
			$info.text = "Key Needed"
			$info.visible = true
		else:
			$info.visible = false
			

func show_menus():
	$sounds/ui_sound.play()
	if $Back_button.visible == false:
		$Back_button.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		$Back_button.hide()
		$Back_button.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func do_action():
	if $Turret/action_ray.is_colliding():
		var c = $Turret/action_ray.get_collider()
		if c.is_in_group("Item"):
			var groups = c.get_groups()
			for property in groups:
				items.append(property)
			c.hide()
			print(items)
			c.free()

func die():
	$die_panel/AnimationPlayer.play("respawn")
	#$Hud/die_panel.show()

extends KinematicBody

#export(NodePath) onready var turret = get_node(turret) as Spatial
const IDLE = 0
const ATTACK = 1
const DEFEND = 2
const FLEE = 3
const DEAD = 4

var state = 0


var velocity = Vector3.ZERO
var speed = 8.0
var rotation_speed = 4
var ground_acc = 15.0
var air_acc = 2
var jump_power = 20
var jumping = false
var health = 180
var max_health = 80
var current_gun = null
var bullet_num = 0


var can_shoot = true
var is_alive = true

var targets = []
var current_target = null

var health_locations = [] 
var pack_target = WeakRef


func _ready():
	randomize()
	current_gun = Globals.sparkle_gun.instance()
	current_gun.get_node("Timer").wait_time = .1
		
	$Turret.add_child(current_gun)
	Globals.connect("bullet_hit", self, "_bullet_hit")


func initialize(id):
	name = str(id)
	print("enemy " + str(id) + " created")
		
func _process(delta):
	if state != FLEE and is_alive:
		for t in targets: #range(targets.size()):
			$Sightline.look_at(t.global_transform.origin + Vector3(0,1,0), Vector3.UP)
			$Sightline.force_raycast_update()
			if $Sightline.is_colliding():
				#print("is it you?")
				if $Sightline.get_collider().is_in_group("Player"):
					if !current_target:
						current_target = $Sightline.get_collider()
						$target_sound.play()
						#print("i found you!")
				else:
					current_target = null

	state = get_state()


func _physics_process(delta):
	var movement = _get_movement(delta)
	var _acc = 0

	if is_on_floor():
		_acc = ground_acc
	else:
		_acc = air_acc
#
	if current_target:
		velocity.x = lerp(velocity.x, movement.x * speed, _acc * delta)
		velocity.z = lerp(velocity.z, movement.z * speed, _acc * delta)
		velocity.y += Globals.gravity * delta
#

	if !$Tween.is_active():
		var snap = Vector3.ZERO
		if !jumping and is_on_floor():
			snap = Vector3.DOWN
			velocity.y = 0
		elif jumping:
			snap = Vector3.ZERO
			jumping = false
			
		velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true)
		
		
func _get_movement(delta):
	
	var dir = Vector3.DOWN
	
	if state == DEAD:
		dir = Vector3.ZERO
		return dir
		
	if state == IDLE:
		#print(state)
		dir = do_idle_state()

	if state == ATTACK:
		#print(state)
		global_transform = rotate_to_target(current_target, delta)
		var t_dir = $Turret.global_transform.looking_at(current_target.global_transform.origin, Vector3.UP)
		$Turret.look_at(current_target.global_transform.origin + Vector3(0,1,0), Vector3.UP)
		$Turret.rotation.z = 0
		$Turret.rotation.y = 0
		dir = do_attack_state()

	if state == DEFEND:
		#print(state)
		global_transform = rotate_to_target(current_target, delta)
		dir = do_defend_state()
		
	if state == FLEE:
		#print(state)
		#global_transform = rotate_to_target(current_target, delta)
		dir = do_flee_state()
		if current_target:
			global_transform = rotate_to_target(current_target, delta)
		
	return dir.normalized()

func rotate_to_target(target, delta):
	#print("last state is :" + str(state))
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.global_transform.origin.x, global_transform.origin.y, target.global_transform.origin.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rotation_speed * delta)
	return Transform(Basis(wrotation), global_transform.origin)
		
func rotate_away_from_target(target, delta):
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.global_transform.origin.x, global_transform.origin.y, target.global_transform.origin.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), -rotation_speed * delta)
	return Transform(Basis(wrotation), global_transform.origin)	

func take_damage(dmg, bullet_owner):
	if is_alive:
		$Hit_sound.play()
	else:
		explode()
	health -= dmg
	if health <=0:
		#health = 100
		is_alive = false
		state = DEAD
		explode()

	
func _bullet_hit(damage, bullet_owner):
	pass

func get_health(health_val):
	health +=health_val
	if health > max_health:
		health = max_health
		
	if targets.size() > 0:
		current_target = targets[0]
	else:
		current_target = null

func _on_Area_body_entered(body):
	#print("where ARE you?")
	if body.is_in_group("Player"):		
		targets.append(body)

func _on_Area_body_exited(body):
	#print("i've lost you")
	targets.erase(body)
	if body == current_target:
		current_target = null


func _on_scan_timer_timeout():
	#print(targets.size())
	if state != FLEE and is_alive:
		for t in targets: #range(targets.size()):
			$Sightline.look_at(t.global_transform.origin + Vector3(0,1,0), Vector3.UP)
			$Sightline.force_raycast_update()
			if $Sightline.is_colliding():
				#print("is it you?")
				if $Sightline.get_collider().is_in_group("Player"):
					if !current_target:
						current_target = $Sightline.get_collider()
						$target_sound.play()
						#print("i found you!")
				else:
					current_target = null
						
	if state != DEAD:
		state = get_state()

func get_state():
	var _state = IDLE
	if !current_target and is_alive:
		#print("idle")
		_state = IDLE
		
	elif current_target and is_alive:
		if global_transform.origin.distance_to(current_target.global_transform.origin) <= 10 and health > 20:
			#print("defending")
			_state = DEFEND
		if global_transform.origin.distance_to(current_target.global_transform.origin) > 10 and health > 20:
			#print("attacking")
			_state = ATTACK
		if health <= 20:
			#print("run away")
			_state = FLEE
	elif !is_alive:
		_state = DEAD
	#_state = IDLE
	return _state
	
func do_idle_state():
	#print("idle state")
	var dir = Vector3.DOWN
	set_lights(Color.green)
	return dir.normalized()


func do_attack_state():
	#print("attack state")
	var dir = Vector3.DOWN
	if rand_range(0,1) < .05 and $burst_timer.is_stopped():
		$burst_timer.start()
		can_shoot = true
			
	if can_shoot:	
		current_gun.shoot(name, bullet_num)
		bullet_num+=1
		
	dir -= transform.basis.z
	set_lights(Color.red)
	return dir.normalized()
	
func do_defend_state():
	#print("defend state")
	var dir = Vector3.DOWN
	if rand_range(0,1) < .05:
		current_gun.shoot(name, bullet_num)
		bullet_num+=1
	dir += transform.basis.z
	set_lights(Color.yellow)
	return dir.normalized()

func do_flee_state():
	#print("flee state")
	set_lights(Color.cyan)
	var dir = Vector3.DOWN
	
	if pack_target.get_ref():
		$Healthline.look_at(pack_target.get_ref().global_transform.origin, Vector3.UP)
		$Healthline.force_raycast_update()

		if $Healthline.is_colliding():
			var collider = $Healthline.get_collider()
			if collider.is_in_group("Healthpack"):
				current_target = collider
				dir -= transform.basis.z
	else:
		if targets.size() > 0:
			current_target = targets[0]

			if rand_range(0,1) < .5:
				dir += transform.basis.x
			else:
				dir -= transform.basis.x

			if is_on_floor() and rand_range(0,1) < .05:
				velocity.y = jump_power
				jumping = true
				current_gun.shoot(name, bullet_num)
				bullet_num+=1					
		else:
			current_target = null
			
	return dir.normalized()


func _on_next_action_timeout():
	pass


func _on_Area_area_entered(area):

	var dupl = false
	if area.is_in_group("Healthpack"):
		#print("found pack")
		
		var p = weakref(area)
		
		pack_target = p
	

func _on_Area_area_exited(area):
	if area.is_in_group("Healthpack"):
		#print("pack lost")
		for h in health_locations:
			#print(h.get_ref())
			if h.get_ref() == area:
				health_locations.erase(h)
		#print(health_locations)
		if current_target == area:
			current_target = null

func set_lights(color):
	if get_tree().has_network_peer():
		rpc("set_lights_remote", color)
	
	$light1/OmniLight.light_color = color
	$light2/OmniLight.light_color = color
	$light3/OmniLight.light_color = color

remote func set_lights_remote(color):
	$light1/OmniLight.light_color = color
	$light2/OmniLight.light_color = color
	$light3/OmniLight.light_color = color
	pass

func explode():
	$Explode_sound.play()
	if get_tree().has_network_peer():
		rpc("explode_remote")
	$Explosion/Particles.emitting = true
	$Explosion/Particles2.emitting = true
	
remote func explode_remote():
	$Explode_sound.play()
	$Explosion/Particles.emitting = true
	$Explosion/Particles2.emitting = true


func _on_burst_timer_timeout():
	can_shoot = false

extends KinematicBody

#export(NodePath) onready var turret = get_node(turret) as Spatial
const IDLE = 0
const ATTACK = 1
const DEFEND = 2
const FLEE = 3
const DEAD = 4

var state = 0


var velocity = Vector3.ZERO
var speed = 10.0
var rotation_speed = 10
var ground_acc = 4.0
var air_acc = 2
var jump_power = 20
var health = 30
var max_health = 35
var current_gun = null
var bullet_num = 0

var is_alive = true

var targets = []
var current_target = null

var health_locations = [] 
var pack_target = WeakRef

var puppet_position = Vector3()
var puppet_velocity = Vector3()
var puppet_rotation = Vector3()

func _ready():
	randomize()
	Globals.connect("bullet_hit", self, "_bullet_hit")


func initialize(id):
	name = str(id)
	print("enemy " + str(id) + " created")
	current_gun = Globals.buzz_saw.instance()
	current_gun.bullet_owner = name
	$Turret.add_child(current_gun)
	$Turret2.add_child(current_gun.duplicate())
		
func _process(delta):
	pass


func _physics_process(delta):
	if !is_alive:
		return
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
		#velocity.y += Globals.gravity * delta * 2
#
	if !is_on_floor():
		velocity.y += Globals.gravity * delta
	elif is_on_floor():# and !jumping:
		#print("setting")
		velocity.y = 0
		

	var snap = -get_floor_normal()
	velocity.y = move_and_slide_with_snap(velocity, snap, Vector3.UP, true).y
		
func _get_movement(delta):
	state = get_state()
	
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
		dir = do_attack_state()

	if state == DEFEND:
		#print(state)
		global_transform = rotate_to_target(current_target, delta)
		dir = do_defend_state()
		
	if state == FLEE:
		dir = do_flee_state()
		if current_target:
			global_transform = rotate_to_target(current_target, delta)
		
	return dir.normalized()

func rotate_to_target(target, delta):
	#print(target)
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.global_transform.origin.x, global_transform.origin.y, target.global_transform.origin.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), (rotation_speed) * delta)
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
	if health <=0 and is_alive:
		#health = 100
		is_alive = false
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
	if body.is_in_group("Player"):
		targets.erase(body)
		
	if body == current_target:
		current_target = null


func _on_scan_timer_timeout():

	current_target = null
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
						#print("i found you!")
						$target_sound.play()
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
		if global_transform.origin.distance_to(current_target.global_transform.origin) > 0 and health > 20:
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
#	if rand_range(0,1) < .05 and is_on_floor():
#		velocity.y = jump_power
	dir -= transform.basis.z
	set_lights(Color.red)
	return dir.normalized()
	
func do_defend_state():
	var dir = Vector3.DOWN
#	if rand_range(0,1) < .05 and is_on_floor():
#		velocity.y = jump_power
	dir -= transform.basis.z
	set_lights(Color.red)
	return dir.normalized()

func do_flee_state():
	#print("flee state")
	set_lights(Color.cyan)
	var dir = Vector3.DOWN
#	if rand_range(0,1) < .05 and is_on_floor():
#		velocity.y = jump_power
	dir -= transform.basis.z
	set_lights(Color.red)
	return dir.normalized()


func _on_next_action_timeout():
	pass

func set_lights(color):
	if get_tree().has_network_peer():
		rpc("set_lights_remote", color)
	
	$light1/OmniLight.light_color = color
	$light2/OmniLight.light_color = color
	
remote func set_lights_remote(color):
	$light1/OmniLight.light_color = color
	$light2/OmniLight.light_color = color

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

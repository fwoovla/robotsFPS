extends Spatial

var can_shoot = true
var bullet_owner = ""
var damage = 0
var ammo_count = 0
var max_ammo = 0

func _ready():
	$Area.global_transform.origin.z  = -.2
	
func shoot(_parent_name, bullet_num):
	$AnimationPlayer.play("buzz")
	bullet_owner = _parent_name


func _on_Area_body_entered(body):
	bullet_owner = get_parent().get_parent().name
	#print(get_parent().get_parent().name)
	if body.has_method("take_damage") and body.name != bullet_owner:
		#print(c)
		damage = int(rand_range(8, 15))
		body.take_damage(damage, bullet_owner)
		Globals.emit_signal("bullet_hit", damage, bullet_owner)

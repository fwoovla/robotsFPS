extends Spatial

var b_tag = "bloop"
var can_shoot = true
var ammo_count = 15
var max_ammo = 15

func shoot(_parent_name, bullet_num):
	if can_shoot and ammo_count > 0:
		$AnimationPlayer.play("shoot")
		$AudioStreamPlayer3D.play(0)
		can_shoot = false
		ammo_count -=1
		$Timer.start()
		var b = Globals.bloop.instance()
		Entities.bullets.add_child(b)
		b.global_transform = $Muzzle.global_transform
		b.bullet_owner = _parent_name
		b.name = _parent_name + str(bullet_num)
		#print(b.name)


func _on_Timer_timeout():
	can_shoot = true

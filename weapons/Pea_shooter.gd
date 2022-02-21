extends Spatial

var b_tag = "pea"
var can_shoot = true
var ammo_count = 50
var max_ammo = 50

func shoot(_parent_name, bullet_num):
	if can_shoot and ammo_count > 0:
		$AudioStreamPlayer3D.play()
		can_shoot = false
		ammo_count -=1
		if ammo_count < 0:
			ammo_count = 0
		$Timer.start()
		var b = Globals.pea.instance()
		Entities.bullets.add_child(b)
		b.global_transform = $Muzzle.global_transform
		b.bullet_owner = _parent_name
		b.name = _parent_name + str(bullet_num)

		#print(b.name)


func _on_Timer_timeout():
	can_shoot = true

extends Spatial

var can_shoot = true
var bullet_owner = ""
var damage = 0
var ammo_count = 80
var max_ammo = 80

func shoot(_parent_name, bullet_num):
	if can_shoot and ammo_count > 0:
		$AudioStreamPlayer3D.play()
		can_shoot = false
		ammo_count -=1
		if ammo_count < 0:
			ammo_count = 0
		$Timer.start()
		var b = Globals.sparkle.instance()
		Entities.bullets.add_child(b)
		b.global_transform = $Muzzle.global_transform
		b.bullet_owner = _parent_name
		bullet_owner = _parent_name
		b.name = _parent_name + str(bullet_num) 
		
		$RayCast.force_raycast_update()
		
		if $RayCast.is_colliding():
			#print($RayCast.get_collider())
			var c = $RayCast.get_collider()
			if c.has_method("take_damage") and c.name != _parent_name:
				#print("hit + " + str(c.name) )
				var shape = $RayCast.get_collider_shape()
				var hit_shape = c.shape_owner_get_owner(shape)
				#print(hit_shape.name)
				#print(c)
				damage = int(rand_range(4, 10))
				if hit_shape.name == "head":
					damage = damage * 4
				if hit_shape.name == "body":
					damage = damage * 3
				c.take_damage(damage, bullet_owner)
				Globals.emit_signal("bullet_hit", damage, bullet_owner)


func _on_Timer_timeout():
	can_shoot = true


extends RayCast

#func _process(delta):
#	if is_colliding():
#		var c = get_collision_point()
#		$Sprite3D.global_transform.origin = c
#		$Sprite3D.transform.origin.z = $Sprite3D.transform.origin.z + .5
#	else:
#		$Sprite3D.global_transform.origin = cast_to
#		$Sprite3D.global_transform.origin.z = $Sprite3D.global_transform.origin.z + 1

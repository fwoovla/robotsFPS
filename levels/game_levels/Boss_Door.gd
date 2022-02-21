extends Spatial

var target_pos = Vector3.ZERO
var closed = true
var speed = 1

func _ready():
	pass
#	var m = $Button/button.mesh.surface_get_material(0)
#	m.albedo_color = Color.maroon
#	m.emission = Color.maroon
#	$Button/button.set_surface_material(0, m)
#	$MeshInstance.transform.origin = $Top_pos.transform.origin
#	$CollisionShape.transform.origin = $Top_pos.transform.origin	
	
func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		print("need key")
		for i in body.items:		
			if i == "Boss_key":
				if closed:
					$Tween.interpolate_property($Door2, "global_transform", $Door2.global_transform, $Door2.global_transform.translated(Vector3(2,0,0)), speed,Tween.TRANS_LINEAR)
					$Tween.interpolate_property($Door, "global_transform", $Door.global_transform, $Door.global_transform.translated(Vector3(-2,0,0)), speed,Tween.TRANS_LINEAR)
					$Tween.start()
					closed = false
					$Timer.start()
					print(closed)


func _on_Timer_timeout():
	$Tween.interpolate_property($Door2, "global_transform", $Door2.global_transform, $Door2.global_transform.translated(Vector3(-2,0,0)), speed,Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Door, "global_transform", $Door.global_transform, $Door.global_transform.translated(Vector3(2,0,0)), speed,Tween.TRANS_LINEAR)
	$Tween.start()
	closed = true

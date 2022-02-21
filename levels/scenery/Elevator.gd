extends RigidBody


var target_pos = Vector3.ZERO
var is_up = true
var speed = 3

func _ready():
	var m = $Button/Button/button.mesh.surface_get_material(0)
	m.albedo_color = Color.maroon
	m.emission = Color.maroon
	$Button/Button/button.set_surface_material(0, m)
	$MeshInstance.transform.origin = $Top_pos.transform.origin
	$CollisionShape.transform.origin = $Top_pos.transform.origin	
	
func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		for i in body.items:		
			if i == "Keycard":
				$AudioStreamPlayer.play()
				if is_up:
					var m = $Button/Button/button.mesh.surface_get_material(0)
					m.albedo_color = Color.greenyellow
					m.emission = Color.greenyellow
					$Button/Button/button.set_surface_material(0, m)
					$Tween.interpolate_property($MeshInstance, "global_transform", $MeshInstance.global_transform, $Bottom_pos.global_transform, speed,Tween.TRANS_LINEAR)
					$Tween.start()
					$Tween.interpolate_property($CollisionShape, "global_transform", $CollisionShape.global_transform, $Bottom_pos.global_transform, speed,Tween.TRANS_LINEAR)
					is_up = false
					$Timer.start()
			


func _on_Timer_timeout():
	var m = $Button/Button/button.mesh.surface_get_material(0)
	m.albedo_color = Color.maroon
	m.emission = Color.maroon
	$Button/Button/button.set_surface_material(0, m)
	$Tween.interpolate_property($MeshInstance, "global_transform", $MeshInstance.global_transform, $Top_pos.global_transform, speed,Tween.TRANS_LINEAR)			
	$Tween.interpolate_property($CollisionShape, "global_transform", $CollisionShape.global_transform, $Top_pos.global_transform, speed,Tween.TRANS_LINEAR)
	$Tween.start()
	is_up = true

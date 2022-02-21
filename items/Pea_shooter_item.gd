extends Spatial

var item = Globals.pea_shooter

signal picked_up

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		body.get_item(item)
		emit_signal("picked_up")
		queue_free()


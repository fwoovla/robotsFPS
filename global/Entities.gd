extends Spatial

var players
var bullets
var enemies
var mobs


func _ready():
	players = Spatial.new()
	bullets = Spatial.new()
	enemies = Spatial.new()
	mobs = Spatial.new()
	add_child(players)
	add_child(bullets)
	add_child(enemies)
	add_child(mobs)
	pass

extends Spatial

export (PackedScene) var _enemy

func _ready():
	randomize()
	var id = 1000 + (randi() % 100)
	instance_enemy(id)

func instance_enemy(id):
				
	print("creating enemy  " +str(id))
	var e = _enemy.instance()
	Entities.mobs.add_child(e)  # can/should I add this to initialize?
	e.initialize(id)
	e.global_transform = global_transform
	

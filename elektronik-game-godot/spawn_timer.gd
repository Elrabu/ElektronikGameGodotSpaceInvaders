extends Timer

class_name SpawnTimer

@export var min_timer = 5
@export var max_timer = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_timer()

func setup_timer():
	var random_timer = randi_range(min_timer, max_timer) 
	self.wait_time = random_timer
	self.stop()
	self.start()

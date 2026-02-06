extends Node

class_name PointsCounter

signal on_points_increased(points: int)

var points = 0

@onready var invader_spawner = $"../InvaderSpawner" as InvaderSpawner

func _ready():
	invader_spawner.invader_destroyed.connect(increase_points)
	
func increase_points(points_to_add: int):
	print("increase_points called with:", points_to_add)
	points += points_to_add
	#print("Points now:", points)
	on_points_increased.emit(points)

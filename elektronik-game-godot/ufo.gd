extends Area2D

class_name Ufo

@export var speed = 200
@onready var sprite_2d = $Sprite2D

func _process(delta):
	position.x -= delta * speed


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

extends Node2D

class_name Player

signal player_destroyed

var controller: Controller
@export var speed = 200
var direction = Vector2.ZERO

@onready var collision_rect: CollisionShape2D = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var explosion = %explosion

var bounding_size_x
var start_bound
var end_bound

func _ready():
	bounding_size_x = collision_rect.shape.get_rect().size.x
	
	var rect = get_viewport().get_visible_rect()
	var camera = get_viewport().get_camera_2d()
	var camera_position = camera.position
	start_bound = (camera_position.x - rect.size.x) / 2
	end_bound = (camera_position.x + rect.size.x) / 2
	
	var controller_host = get_tree().get_current_scene().get_node("Controller")

	if controller_host:
		controller = controller_host.controller
	else:
		push_error("ControllerHost not found in the current scene!")

func _physics_process(delta):
	if controller:
		var raw_x = controller.get_axis_x()

		var move_x = (raw_x - 512.0) / 512.0

		if abs(move_x) < 0.05:
			move_x = 0.0

		var delta_movement = speed * delta * move_x
		
		if (position.x + delta_movement < start_bound + bounding_size_x * transform.get_scale().x ||
		 	position.x + delta_movement > end_bound - bounding_size_x * transform.get_scale().x):
			return
		position.x += delta_movement
	
func on_player_destroyed():
	explosion.play()
	speed = 0
	animation_player.play("destroy")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destroy":
		await get_tree().create_timer(1).timeout
		player_destroyed.emit()
		queue_free()

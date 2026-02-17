extends Node2D

@export var laser_scene: PackedScene
@onready var shoot = %shoot

var can_player_shoot = true
var controller: Controller

func _ready():
	var controller_host = get_tree().get_current_scene().get_node("Controller")

	if controller_host:
		controller = controller_host.controller
	else:
		push_error("ControllerHost not found in the current scene!")

func _physics_process(delta):
	if controller and controller.get_buttons(): #== 1 && can_player_shoot:
		shoot.play()
		can_player_shoot = false
		var laser = laser_scene.instantiate() as Laser
		laser.global_position = get_parent().global_position - Vector2(0, 20)
		get_tree().root.get_node("main").add_child(laser)
		laser.tree_exited.connect(on_laser_destroyed)		

func on_laser_destroyed():
	can_player_shoot = true

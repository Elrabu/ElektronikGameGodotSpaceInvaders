extends Node2D

@export var laser_scene: PackedScene
@onready var shoot = %shoot

var can_player_shoot = true
var controller: Controller
var display: Display

const BTN_A     = 0b00000001  # Bit 0
const BTN_B     = 0b00000010  # Bit 1
const BTN_X     = 0b00000100  # Bit 2
const BTN_Y     = 0b00001000  # Bit 3
const BTN_LB    = 0b00010000  # Bit 4
const BTN_RB    = 0b00100000  # Bit 5
const BTN_START = 0b01000000  # Bit 6

func _ready():
	var controller_host = get_tree().get_current_scene().get_node("Controller")

	if controller_host:
		controller = controller_host.controller
	else:
		push_error("ControllerHost not found in the current scene!")

func _physics_process(_delta):
	var buttons = controller.get_buttons()
	if controller and (buttons & BTN_X) != 0 && can_player_shoot:
		shoot.play()
		can_player_shoot = false
		var laser = laser_scene.instantiate() as Laser
		laser.global_position = get_parent().global_position - Vector2(0, 20)
		get_tree().root.get_node("main").add_child(laser)
		laser.tree_exited.connect(on_laser_destroyed)		

func on_laser_destroyed():
	can_player_shoot = true

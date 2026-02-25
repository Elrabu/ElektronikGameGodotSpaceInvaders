extends Node2D

class_name Player

const BTN_A     = 0b00000001  # Bit 0
const BTN_B     = 0b00000010  # Bit 1
const BTN_X     = 0b00000100  # Bit 2
const BTN_Y     = 0b00001000  # Bit 3
const BTN_LB    = 0b00010000  # Bit 4
const BTN_RB    = 0b00100000  # Bit 5
const BTN_START = 0b01000000  # Bit 6

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

var pause_menu_scene := preload("res://pause_menu.tscn")
var pause_menu: CanvasLayer = null
var is_paused := false
var btn_start_was_pressed := false

func _ready():
	position.y = 400
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
		var buttons = controller.get_buttons()
		var btn_start_pressed = (buttons & BTN_START) != 0
		if btn_start_pressed and not btn_start_was_pressed:
			if is_paused:
				_resume()
			else:
				_pause()
		btn_start_was_pressed = btn_start_pressed
		
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

func _pause():
	is_paused = true
	get_tree().paused = true
	pause_menu = pause_menu_scene.instantiate()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(pause_menu)
	pause_menu.resume_requested.connect(_resume)
	pause_menu.quit_requested.connect(_quit_to_launcher)


func _resume():
	is_paused = false
	get_tree().paused = false
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null

func _quit_to_launcher():
	get_tree().paused = false
	_launch_launcher()
	get_tree().quit()

func _launch_launcher():
	var launcher_path: String
	if OS.get_name() == "Windows":
		launcher_path = OS.get_executable_path().get_base_dir().path_join("..\\..\\launcher.exe")
	else:
		launcher_path = OS.get_executable_path().get_base_dir().path_join("../../launcher.arm64")
	
	if FileAccess.file_exists(launcher_path):
		OS.create_process(launcher_path, [])
	else:
		push_error("Launcher not found at: " + launcher_path)

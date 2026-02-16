extends CanvasLayer

@onready var invader_1_texture = %Invader1Texture
@onready var invader_1_label = %Invader1Label
@onready var invader_2_texture = %Invader2Texture
@onready var invader_2_label = %Invader2Label
@onready var invader_3_texture = %Invader3Texture
@onready var invader_3_label = %Invader3Label
@onready var button = $MarginContainer/VBoxContainer/HBoxContainer/Button
@onready var timer = $Timer

var control_array = []
var controller: Controller

# Called when the node enters the scene tree for the first time.
func _ready():
	var controller_host = get_tree().get_current_scene().get_node("ControllerHost")

	if controller_host:
		controller = controller_host.controller
	else:
		push_error("ControllerHost not found in the current scene!")

	control_array = [
		[invader_1_texture, invader_1_label],
		[invader_2_texture, invader_2_label],
		[invader_3_texture, invader_3_label],
		[button]
	]

	for entry in control_array:
		for control in entry:
			(control as Control).visible = false

func _physics_process(delta):
	if controller and controller.get_buttons() == 1:
		get_tree().change_scene_to_file("res://main.tscn")
	
func show_next_control():
	if control_array.is_empty():
		timer.stop()
		timer.queue_free()
		return

	var entry = control_array.pop_front()
	for control in entry:
		(control as Control).visible = true

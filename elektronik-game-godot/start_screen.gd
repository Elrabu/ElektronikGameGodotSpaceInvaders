extends CanvasLayer

@onready var invader_1_texture = %Invader1Texture
@onready var invader_1_label = %Invader1Label
@onready var invader_2_texture = %Invader2Texture
@onready var invader_2_label = %Invader2Label
@onready var invader_3_texture = %Invader3Texture
@onready var invader_3_label = %Invader3Label
@onready var button = %Button
@onready var timer = $Timer

var control_array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	control_array.append_array([invader_1_texture, invader_1_label, invader_2_texture, invader_2_label, invader_3_texture, invader_3_label, button])
	
	for control in control_array:
		(control as Control).visible = false

func load_game():
	get_tree().change_scene_to_file("res://main.tscn")

func show_next_control():
	var control = control_array.pop_front() as Control
	if control != null:
		control.visible = true
	else:
		timer.stop()
		timer.queue_free()

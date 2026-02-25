extends Node2D

class_name InvaderSpawner

signal invader_destroyed(points: int)
signal game_won
signal game_lost

const ROWS = 5
const COLUMNS = 11
const HORIZONTAL_SPACING = 75
const VERTICAL_SPACING = 75
const INVADER_HEIGHT = 24
const START_Y_POSITION = -50
const INVADERS_POSITION_X_INCREMENT = 20
const INVADERS_POSITION_Y_INCREMENT = 40

var movement_direction = 1
var invader_scene = preload("res://invader.tscn")
var invader_shot_scene = preload("res://invader_shot.tscn")

var invader_total_count = ROWS * COLUMNS
var invader_destroyed_count = 0

@export var base_move_interval := 0.8      # starting speed (slow)
@export var speedup_per_kill := 0.015         # how much faster per invader
@export var min_move_interval := 0.08         # max speed cap
var sound_index := 0
#Audio Array
var fastinvader_sounds: Array[AudioStreamPlayer2D]

# NODE REFERENCES
@onready var movement_timer = $MovementTimer
@onready var shot_timer = $ShotTimer
@onready var invader_boom = $invader_boom
@onready var fastinvader_1 = $fastinvader1
@onready var fastinvader_2 = $fastinvader2
@onready var fastinvader_3 = $fastinvader3
@onready var fastinvader_4 = $fastinvader4

var display: Display


# Called when the node enters the scene tree for the first time.
func _ready():
	var display_host = get_tree().get_current_scene().get_node("DisplayHost")
	
	if display_host:
		display = display_host.display
	else:
		push_error("DisplayHost not found in the current scene!")


	movement_timer.timeout.connect(move_invaders)
	shot_timer.timeout.connect(on_invader_shot)
	
	fastinvader_sounds = [
		fastinvader_1,
		fastinvader_2,
		fastinvader_3,
		fastinvader_4
	]
	
	movement_timer.wait_time = base_move_interval
	movement_timer.start()
	
	var invader_1_res = preload("res://Resources/invader_1.tres")
	var invader_2_res = preload("res://Resources/invader_2.tres")
	var invader_3_res = preload("res://Resources/invader_3.tres")
	
	var invader_config
	
	for row in ROWS:
		if row == 0:
			invader_config = invader_1_res
		elif  row == 1 || row == 2:
			invader_config = invader_2_res
		elif row == 3 || row == 4:
			invader_config = invader_3_res
			
		var row_width = (COLUMNS * invader_config.width * 3) + ((COLUMNS - 1) * HORIZONTAL_SPACING)

		var start_x_position = (position.x - row_width) / 2
		
		for col in COLUMNS:
			
			var x = start_x_position + (col * invader_config.width * 3) + (col * HORIZONTAL_SPACING)
			var y = START_Y_POSITION + (row * INVADER_HEIGHT) + (row * VERTICAL_SPACING)
			
			var spawn_position = Vector2(x, y)
			spawn_invader(invader_config, spawn_position)

func spawn_invader(invader_config, spawn_position:Vector2):
	var invader = invader_scene.instantiate() as Invader
	invader.config = invader_config
	invader.global_position = spawn_position
	invader.on_invader_destroyed.connect(on_invader_destroyed)
	add_child(invader)

func move_invaders():
	position.x += INVADERS_POSITION_X_INCREMENT * movement_direction

	fastinvader_sounds[sound_index].play()
	sound_index = (sound_index + 1) % fastinvader_sounds.size()
	


func _on_left_wall_area_entered(_area):
	if(movement_direction == -1):
		position.y += INVADERS_POSITION_Y_INCREMENT 
		movement_direction *= -1


func _on_right_wall_area_entered(_area):
	if(movement_direction == 1):
		position.y += INVADERS_POSITION_Y_INCREMENT
		movement_direction *= -1
		
func on_invader_shot():
	var random_child_position = get_children().filter(func (child ): return child is Invader).map(func (invader): return invader.global_position).pick_random()
	
	var invader_shot = invader_shot_scene.instantiate() as InvaderShot
	invader_shot.global_position = random_child_position
	get_tree().root.add_child(invader_shot)

func on_invader_destroyed(points: int):
	display.show_text("+ " + str(points))
	invader_boom.play()
	invader_destroyed.emit(points)
	invader_destroyed_count += 1
	await get_tree().create_timer(2.0).timeout
	display.clear()

	var new_time = base_move_interval - (invader_destroyed_count * speedup_per_kill) #accelerate game
	movement_timer.wait_time = max(new_time, min_move_interval)

	if invader_destroyed_count == invader_total_count:
		game_won.emit()
		shot_timer.stop()
		movement_timer.stop()
	


func _on_bottom_wall_area_entered(_area):
	movement_direction = 0
	game_lost.emit()

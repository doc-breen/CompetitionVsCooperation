extends Node2D

onready var farm_time = $FoodClock
const SCREEN_WIDTH = 800
const SCREEN_HEIGHT = 600
var food_scene = preload("res://Food.tscn")
var dude_scene = preload("res://Entity.tscn")
onready var fps_counter = $CanvasLayer/FpsCounter
onready var population_counter = $CanvasLayer/PopCounter
onready var resource_counter = $CanvasLayer/FoodCounter
# Add left-click to interact and right-click to bring up menu
# which determines left-click behavior
onready var pop_menu = $CanvasLayer/PopupMenu
var click_state:= 0

func _ready():
	# set food regen rate in seconds
	farm_time.wait_time = .5
	# start with a few extra randomly placed
	spawn_food()
	spawn_food()
	spawn_food()

func _process(_delta) -> void:
	# display FPS and other counters on top right of screen
	var fps = String(Engine.get_frames_per_second())
	fps_counter.text = "FPS: " + fps
	var population = get_tree().get_nodes_in_group('Agents').size()
	population_counter.text = "N: " + String(population)
	var resources = get_tree().get_nodes_in_group('Resource').size()
	resource_counter.text = "R: " + String(resources)
	

func _unhandled_input(_event):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		left_mouse_behavior()
	
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		var pos = get_global_mouse_position()
		pop_menu.rect_position = pos
		pop_menu.popup()

func left_mouse_behavior():
	match click_state:
		0:
			spawn_food()
		1:
			var rand_clr = Color()
			rand_clr.r8 = Universals.rng.randi_range(0,255)
			rand_clr.g8 = Universals.rng.randi_range(0,255)
			rand_clr.b8 = Universals.rng.randi_range(0,255)
			
			_on_clone(get_global_mouse_position(),rand_clr)
	pass

func spawn_food():
	var food_pos = Vector2()
	food_pos.x = Universals.rng.randi_range(0,SCREEN_WIDTH)
	food_pos.y = Universals.rng.randi_range(0,SCREEN_HEIGHT)
	var food_instance = food_scene.instance()
	food_instance.position = food_pos
	add_child(food_instance)


func _on_FoodClock_timeout():
	spawn_food()

func _on_clone(pos,bod):
	var dude_instance = dude_scene.instance()
	dude_instance.position = pos
	add_child(dude_instance)
	dude_instance.body_type = bod


func _on_PopupMenu_index_pressed(index):
	_set_click_behavior(index)

func _set_click_behavior(mode):
	click_state = mode

func _on_PopupMenu_gui_input(event):
	if event is InputEventMouseButton:
		get_tree().set_input_as_handled()

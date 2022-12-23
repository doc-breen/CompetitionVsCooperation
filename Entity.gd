extends Node2D
class_name Entity

var energy:= 10.0	# Internal energy depot
enum state {PASSIVE, ACTIVE}	# Type of particle
const SLEEP_COEF = 0.003
const WAKE_COEF = 0.009
const FATNSASSY = 15.0
const FOOD_EN = 5.0
const REPROD_EN = 10.0
var birth_time: float
var adult = false
export var body_type = Color()
var drift_C = Universals.rng.randi_range(-5,5)
onready var agent = $RigidBody2D
signal clone(pos,bod)

func _ready():
	birth_time = Time.get_ticks_msec()
	var environ = $".."
# warning-ignore:return_value_discarded
	connect('clone',environ,'_on_clone')


func _physics_process(_delta):
	# energy decay
	if agent.sleeping:
#		# no movement, lower decay rate
		energy = (1-SLEEP_COEF)*energy
#
	energy = (1-WAKE_COEF)*energy
	# death condition
	if energy <= 0.0000001:
		_kill()
	# clone condition
	if energy > FATNSASSY and adult == true:
		_reproduce()
	
	# translational drift
	var drift_motion = Vector2(Universals.rng.randfn(0,1),Universals.rng.randfn(0,1))
	agent.apply_central_impulse(drift_motion)

func _get_direction() -> Vector2:
	var direc:= Vector2()
	direc.x = cos(agent.rotation_degrees)
	direc.y = sin(agent.rotation_degrees)
	return direc.normalized()

func _on_Area2D_area_entered(area):
	if 'Food' in area.get_parent().name:
		_eat_food(area)
		
	elif 'Entity' in area.get_parent().get_parent().name:
		_fight()

func _fight():
	# Die with low probability
	var roll = Universals.rng.randi_range(0,11)
	if roll == 0:
		# Kill self
		_kill()

func _eat_food(area):
	energy += FOOD_EN
	area.get_parent().queue_free()


func _kill():
	var life_time = Time.get_ticks_msec()-birth_time
	print(life_time)
	self.queue_free()

func _reproduce():
	energy -= REPROD_EN
	var new_pos = agent.get_global_transform().get_origin()
	var new_bod = body_type
	var mut = Universals.rng.randfn(0,1)
	new_bod.r8 += 2*mut
	emit_signal('clone',new_pos,new_bod)


func _on_DriftClock_timeout():
	agent.sleeping = false
	# angular drift
	var drift_angle = Universals.rng.randfn(drift_C,3)
	agent.apply_torque_impulse(drift_angle)
	# dart forward
	var speed = 5
	var heading = _get_direction()
	agent.apply_central_impulse(8*speed*heading)


func _on_Development_timeout():
	adult = true
	body_type.g += Universals.rng.randfn(0,.5)
	body_type.b += Universals.rng.randfn(0,.5)
	self.modulate = body_type

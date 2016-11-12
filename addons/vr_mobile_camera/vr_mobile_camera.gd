###############################################################################################################
#                                             VR MOBILE CAMERA v. 0.5                                         #
#                                              OFFICINE PIXEL s.n.c.                                          #
#                                              www.officinepixel.com                                          #
###############################################################################################################
extends Spatial
export var walking_speed = 1.0
export(int) var magnetometer_interpolation = 8
export(bool) var enable_yaw = true
export(bool) var enable_pitch = true
export(bool) var enable_roll = true
export(bool) var show_data = false

var stereo_camera = null

func get_stereo_camera():
	return stereo_camera

func _ready():	
	# Cameras are now setup in stereo_camera.gd but we do get a link to it
	
	stereo_camera = get_node("origin/yaw/pitch/roll/stereo_camera")
	
	rotate_vr_mobile_camera( mag_orientation(1) )
	set_process(true)

var counter = 0
func _process(delta):
	#rotate camera fake camera
	var r = null
	if Input.get_gyroscope() == Vector3(0,0,0): 
		r = mag_orientation( magnetometer_interpolation )
	else:
		if counter == 0:
			counter = 1
			r = mag_orientation(1)
		else:
			r = gyr_orientation(delta)
	# rotate camera
	rotate_vr_mobile_camera(r)
	# move camera
	get_node("origin").translate( Vector3(sin(r.y)*r.x*walking_speed, 0, cos(r.y)*r.x*walking_speed))
	# show data
	if show_data:
		update_sensors_data(r)

# VR CAMERA ROTATION
func rotate_vr_mobile_camera(r):
	if enable_yaw:
		get_node("origin/yaw").set_rotation(Vector3(0,r.y,0))
	if enable_pitch:
		get_node("origin/yaw/pitch").set_rotation(Vector3(r.x,0,0))
	if enable_roll:
		get_node("origin/yaw/pitch/roll").set_rotation(Vector3(0,0,r.z))
	# transformation is now appied to real cameras in stereo_camera.gd

# MAGNOMETER
func mag_orientation(samples):
	var a = get_filtered_accelerometer(samples)
	#if OS.get_name() == "iOS":
	#	a = a.rotated(Vector3(0,0,1), PI+PI/2)
	var m = get_filtered_magnetometer(samples)
	var roll = 0
	var pitch = 0
	if OS.get_name() == "Android":
		roll = atan2( a.x, -a.y )
		a = a.rotated(Vector3(0,0,1),roll)
		pitch = PI / 2 + atan2( a.y, -a.z )
	elif OS.get_name() == "iOS":
		roll = PI / 2 + atan2( a.x, a.y )
		a = a.rotated(Vector3(0,0,1),roll)
		pitch = PI / 2 + atan2( a.x, -a.z )
	else:
		return Vector3(0.0, 0.0, 0.0)

	get_node("magneto").set_translation(m)
	get_node("compass").set_rotation(Vector3( pitch, 0, roll))
	get_node("compass/center").look_at(get_node("magneto").get_global_transform().origin, Vector3(0,1,0))
	get_node("compass").set_rotation(Vector3(0,0,0))
	var c = get_node("compass/center").get_global_transform().origin
	var r = get_node("compass/center/target").get_global_transform().origin
	var yaw = -Vector2(c.x,c.z).angle_to_point(Vector2(r.x,r.z))
	return Vector3( pitch, yaw, roll)

# GYROSCOPE
func gyr_orientation(delta):
	var a = get_filtered_accelerometer(4)
	var g = get_filtered_gyroscope(1)
	var aroll = 0
	var apitch = 0
	#if OS.get_name() == "Android":
	aroll = atan2( a.x, -a.y )
	a = a.rotated(Vector3(0,0,1),aroll)
	apitch = PI/2 + atan2( a.y, -a.z )
	#elif OS.get_name() == "iOS":
	#	aroll = PI/2 + atan2( a.x, a.y )
	#	a = a.rotated(Vector3(0,0,1),aroll)
	#	apitch = PI/2 + atan2( a.x, -a.z )
	var yaw = get_node("origin/yaw").get_rotation().y
	var pitch = get_node("origin/yaw/pitch").get_rotation().x*.99 + apitch*.01
	var roll = (get_node("origin/yaw/pitch/roll").get_rotation().z*.99 + aroll*.01)
	#if OS.get_name() == "iOS":
	#	roll = -roll + PI/2
	var v = Vector3( pitch, yaw, roll)
	g = g.rotated(Vector3(0,0,1), roll)
	g = g.rotated(Vector3(1,0,0), pitch)
	v = v + (Vector3(g.x,-g.y,g.z)*delta)
	return v
	
# FILTER DATA
var acc_buffer = []
func get_filtered_accelerometer(samples):
	var vect = Vector3(0,0,0)
	if samples>1:
		vect = filter(acc_buffer, Input.get_accelerometer(), samples )
	else:
		vect = Input.get_accelerometer()
	return  vect

var mag_buffer = []
func get_filtered_magnetometer(samples):
	var vect = Vector3(0,0,0)
	if samples>1:
		#var vect = filter(mag_buffer, -Input.get_magnetometer().normalized(), samples, true)
		vect = filter(mag_buffer, -Input.get_magnetometer(), samples, true)
	else:
		vect = -Input.get_magnetometer()
	return vect

var gyr_buffer = []
func get_filtered_gyroscope(samples):
	var vect = Vector3(0,0,0)
	if samples>1:
		vect = filter(gyr_buffer, Input.get_gyroscope(), samples, true)
	else:
		vect = Input.get_gyroscope()
	return vect

func filter(buffer, input, samples,  debug=false):
	var max_samples = 180
	buffer.push_front(input)
	if buffer.size()>max_samples:
		buffer.pop_back()
	var average=Vector3(0,0,0)
	if samples>buffer.size():
		samples = buffer.size()
	for i in range(samples):
		average +=buffer[i]
	average = average/samples
	return average
	
func update_sensors_data(r):
		get_node("accelerometer").set_text("accelerometer:    " + str(Input.get_accelerometer().x).pad_decimals(2) + "   " + str(Input.get_accelerometer().y).pad_decimals(2) + "   " + str(Input.get_accelerometer().z).pad_decimals(2))
		get_node("magnometer").set_text("magnetometer:   " + str(Input.get_magnetometer().x).pad_decimals(2) + "   " + str(Input.get_magnetometer().y).pad_decimals(2) + "   " + str(Input.get_magnetometer().z).pad_decimals(2) )
		get_node("gyroscope").set_text("gyroscope:   " + str(Input.get_gyroscope().x).pad_decimals(2) + "   " + str(Input.get_gyroscope().y).pad_decimals(2) + "   " + str(Input.get_gyroscope().z).pad_decimals(2) )
		
		get_node("label_yaw").set_text("yaw:   " + str(r.y ))
		get_node("label_pitch").set_text("pitch:   " + str(r.x ))
		get_node("label_roll").set_text("roll:   " + str(r.z ))

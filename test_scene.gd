extends Spatial

var origin = null
var camera = null
var speed = 1.0
var rotspeed = 1.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	origin = get_node("Origin")
	camera = origin.get_node("stereo_camera")
	
	setInfo()

	set_process(true)
	set_process_input(true)

func _process(delta):
	# Test for escape to close application
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()	

	var rotation = origin.get_rotation()

	if (Input.is_key_pressed(KEY_UP)):
#		origin.translate( Vector3(sin(rotation.y)*-speed, 0, -cos(rotation.y)*-speed))
		origin.translate( Vector3(0, 0, -speed))
	if (Input.is_key_pressed(KEY_DOWN)):
#		origin.translate( Vector3(sin(rotation.y)*speed, 0, -cos(rotation.y)*speed))
		origin.translate( Vector3(0, 0, speed))

	if (Input.is_key_pressed(KEY_LEFT)):
		rotation.y += delta * rotspeed
	if (Input.is_key_pressed(KEY_RIGHT)):
		rotation.y -= delta * rotspeed
	
	origin.set_rotation(rotation)
	
	# position these on our right viewport
	var right_offset = camera.get_right_viewport_offset()
	get_node("IOD_right").set_pos(Vector2(right_offset, 5))
	get_node("Convergence_right").set_pos(Vector2(right_offset, 30))
	
	
func _input(event):
	if (event.type == InputEvent.KEY):
		# TODO figure out why keyboard input is doubling up, need to check for key down?
		
		var changed = false
		var distance = camera.get_eye_distance()
		var convergence = camera.get_eye_convergence()
		
		if (event.scancode == KEY_MINUS):
			distance -= 0.05
			if (distance < 0.05):
				distance = 0.05
			changed = true

		if (event.scancode == KEY_EQUAL):
			distance += 0.05
			if (distance > 10.0):
				distance = 10.0
			changed = true

		if (event.scancode == KEY_BRACELEFT):
			convergence -= 1.0
			if (convergence < 1.0):
				convergence = 1.0
			changed = true

		if (event.scancode == KEY_BRACERIGHT):
			convergence += 1.0
			if (convergence > 4000.0):
				convergence = 4000.0
			changed = true

		if (changed):
			camera.set_camera(distance,convergence)
		
			setInfo()
			
			get_tree().set_input_as_handled()

func setInfo():
	# write in stereo :)
	get_node("IOD_left").set_text("IOD: " + str(camera.get_eye_distance()))
	get_node("IOD_right").set_text("IOD: " + str(camera.get_eye_distance()))

	get_node("Convergence_left").set_text("Convergence: " + str(camera.get_eye_convergence()))
	get_node("Convergence_right").set_text("Convergence: " + str(camera.get_eye_convergence()))
	
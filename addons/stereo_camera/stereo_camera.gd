###############################################################################################################
#                                              Stereo Camera v. 0.1                                           #
#                                                  Bastiaan Olij                                              #
#                                                                                                             #
#                                                                                                             #
#                       Based on VR camera from OFFICINE PIXEL s.n.c. www.officinepixel.com                   #
###############################################################################################################
extends Spatial

export var eyes_distance = .65
export var eyes_convergence = 45.0
export var fov = 60
export var near = 0.1
export var far = 200

var left_eye = null
var right_eye = null

func get_eye_distance():
	return eyes_distance
	
func get_eye_convergence():
	return eyes_convergence
	
func get_right_viewport_offset():
	return get_node("ViewportSprite_right").get_offset().x
	
func set_camera(p_eye_distance, p_eye_convergence):
	if ((eyes_distance == p_eye_distance) && (eyes_convergence == p_eye_convergence)):
		return
		
	eyes_distance = p_eye_distance
	eyes_convergence = p_eye_convergence

	left_eye.set_eye(1, eyes_distance, eyes_convergence)
	right_eye.set_eye(2, eyes_distance, eyes_convergence)

func resize():
	# Called when the main window resizes, resizes our viewports accordingly
	var screen_size = OS.get_window_size()
	get_node("Viewport_left").set_rect(Rect2(Vector2(0,0),Vector2(screen_size.x/2,screen_size.y)))
	get_node("Viewport_right").set_rect(Rect2(Vector2(0,0),Vector2(screen_size.x/2,screen_size.y)))
	get_node("ViewportSprite_right").set_offset(Vector2(screen_size.x/2,0))	

func _ready():
	# Make sure we learn about resizing the window
	var root = get_node("/root")
	root.connect("size_changed",self,"resize")

	# Scale viewports according to window size
	resize()

	# get our eyes for easy access
	left_eye = get_node( 'Viewport_left/Camera_left' )
	right_eye = get_node( 'Viewport_right/Camera_right' )
	
	# use double aspect ratio on PC/Mac, our output will be stretched and overlaid
	var OSName = OS.get_name()
	if ((OSName == "OSX") || (OSName == "Windows") || (OSName == "WinRT") || (OSName == "X11")):
		left_eye.set_keep_aspect_mode(2)
		right_eye.set_keep_aspect_mode(2)

	# make sure our cameras are setup properly
	left_eye.set_perspective(fov, near, far)
	left_eye.set_eye(1, eyes_distance, eyes_convergence)
	right_eye.set_perspective(fov, near, far)
	right_eye.set_eye(2, eyes_distance, eyes_convergence)

	# TODO find a way to determine if we need to double the aspect ratio especially once we implement Left/Right buffer when supported
	# double aspect ratio is ONLY needed for splitscreen when the output is meant for a monitor or TV 
	
	# make sure we get process updates
	set_process(true)

func _process(delta):
	var transform = get_global_transform()
	left_eye.set_global_transform(transform)
	right_eye.set_global_transform(transform)
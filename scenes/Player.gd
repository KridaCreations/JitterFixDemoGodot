extends CharacterBody3D


@onready var headNode = $head
@onready var bottomRay = $bottomRay

@export var m_speed = 30
@export var m_gravity = 2
@export var m_jumpVelocity = 25
@export var m_friction = 0.6
@export var m_maxSpeed = 5

@onready var cameraMount = $head/cameraMount
@onready var cameraMountPrevGlobalTransform = $head/cameraMount.global_transform
@onready var cameraMountCurrGlobalTransform = $head/cameraMount.global_transform
@onready var camera = $head/camera


@onready var gunMeshMount = $head/gunNode/gunMeshMount
@onready var gunMeshMountPrevGlobalTransform = $head/gunNode/gunMeshMount.global_transform
@onready var gunMeshMountCurrGlobalTransform = $head/gunNode/gunMeshMount.global_transform
@onready var gunMesh = $head/gunNode/gunMesh


var takeMouseMovementInput = true
var update = false




# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var debugFrameRateLabelId = null

func _ready():
	pass

func _input(event):	
	#movement of player with mouse movement......
	if (event is InputEventMouseMotion) and (takeMouseMovementInput):
		rotation_degrees.y -= event.relative.x * 1 / 10
		headNode.global_rotation_degrees.x = clamp(headNode.global_rotation_degrees.x - (event.relative.y* 1 / 10),-40,90)

		

func _process(delta):
	
	#this condition will make the code stop responding to the mouse movement (i added this for debugging purposes)
	if(Input.is_action_just_pressed("takeNoMouseMovementInput")):
		takeMouseMovementInput = !takeMouseMovementInput
	
	#handling the windows mode and Cursor Mode
	if (Input.is_action_just_pressed("mouseMode")):
		if(Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):	
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


	#below is the code for fixing jitter....  (comment this part of the code if you want to see the diff)
	if(update):
		update = false
		cameraMountPrevGlobalTransform = cameraMountCurrGlobalTransform
		cameraMountCurrGlobalTransform = cameraMount.global_transform
		
		gunMeshMountPrevGlobalTransform = gunMeshMountCurrGlobalTransform
		gunMeshMountCurrGlobalTransform = gunMeshMount.global_transform
	
	#fixing jitter for camera  (comment this part of the code if you want to see the diff)
	camera.set_as_top_level(true) #deattaching from parent 
	camera.global_transform = cameraMountPrevGlobalTransform.interpolate_with(cameraMountCurrGlobalTransform,Engine.get_physics_interpolation_fraction())

	#fixing jitter for gunMesh  (comment this part of the code if you want to see the diff)
	gunMesh.set_as_top_level(true)
	gunMesh.global_transform = gunMeshMountPrevGlobalTransform.interpolate_with(gunMeshMountCurrGlobalTransform,Engine.get_physics_interpolation_fraction())



func _physics_process(delta):
	update = true
	
	
	
	#movement related code........
	velocity.x = 0
	velocity.z = 0
	var isOnFloor = bottomRay.is_colliding()
	if(isOnFloor == false):
		velocity.y -= m_gravity
	else:
		velocity.y = 0
	
	var frontDir = to_global(Vector3(0,0,-1)) - to_global(Vector3.ZERO)
	frontDir = frontDir.normalized()
	var leftDir = to_global(Vector3(-1,0,0)) - to_global(Vector3.ZERO)
	leftDir = leftDir.normalized()
	var planarMovement = Vector2.ZERO
	if(Input.is_action_pressed("ui_up")):
		planarMovement.x += 1
	if(Input.is_action_pressed("ui_down")):
		planarMovement.x -= 1
	if(Input.is_action_pressed("ui_left")):
		planarMovement.y += 1
	if(Input.is_action_pressed("ui_right")):
		planarMovement.y -= 1
	if(Input.is_action_just_pressed("ui_accept") and (isOnFloor)):
		velocity.y += m_jumpVelocity 
	
	velocity += (frontDir * (planarMovement.x))*m_speed
	velocity += (leftDir * (planarMovement.y))*m_speed
	set_velocity(velocity)
	
	var tempCollisionBody = move_and_collide(velocity * delta,true)
	var remVelocity
	if(tempCollisionBody != null):
		var collNormal = tempCollisionBody.get_normal()
		remVelocity = velocity - (velocity.project(collNormal))
		move_and_collide(remVelocity * delta,false)
	else:
		move_and_collide(velocity * delta,false)
		


	


	



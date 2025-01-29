extends RigidBody3D
@onready var carMesh = $MeshInstance3D
@onready var groundRay = $MeshInstance3D/RayCast3D

var sphereOffset = Vector3.DOWN
var acceleration = 35.0
var steering = 18.0
var turnSpeed = 4.0
var turnStopLimit = 0.75

var speedInput = 0
var turnInput = 0


# Called when ethe node enters the scene tree for the first time.
func _physics_process(delta):
	carMesh.position = position + sphereOffset
	if groundRay.is_colliding():
		apply_central_force(-carMesh.global_transform.basis.z * speedInput)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not groundRay.is_colliding():
		return
	speedInput = Input.get_axis("brake", "accelerate")
	turnInput = Input.get_axis("steerRight", "steerLeft") * deg_to_rad(steering)
	if linear_velocity.length() > turnStopLimit:
		var newBasis = carMesh.global_transform.basis.rotated(carMesh.global_transform.basis.y, turnInput)
		carMesh.global_transform.basis = carMesh.global_transform.basis.slerp(newBasis, turnSpeed * delta)
		carMesh.global_transform = carMesh.global_transform.orthonormalized()
	

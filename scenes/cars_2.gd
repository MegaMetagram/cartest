extends RigidBody3D

#parameters
var hoverHeight: float = 1.0
var springStrength: float = 3.0
var damping: float = 3
var rayCastNodes: Array = []

@onready var botLeftRC = $CollisionShape3D/botLeftRC
@onready var botRightRC = $CollisionShape3D/botRightRC
@onready var topLeftRC = $CollisionShape3D/topLeftRC
@onready var topRightRC = $CollisionShape3D/topRightRC


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get raycasts at start
	rayCastNodes = [$CollisionShape3D/topLeftRC, $CollisionShape3D/topRightRC, $CollisionShape3D/botLeftRC, $CollisionShape3D/botRightRC]

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var totalForce = Vector3.ZERO
	var totalTorque = Vector3.ZERO

	for raycast in rayCastNodes:
		if raycast.is_colliding():
			#distance to ground
			var collisionPoint = raycast.get_collision_point()
			var distance = (raycast.global_transform.origin - collisionPoint).length()

			#hover height
			var hoverForce = (hoverHeight - distance) * springStrength
			hoverForce -= state.get_linear_velocity().y * damping

			#only upwards force
			if hoverForce > 0:
				var force = Vector3(0, hoverForce, 0)
				totalForce += force
				state.apply_force(force, raycast.global_transform.origin)

				#torque tilt correction calculations
				var relativePosition = raycast.global_transform.origin - global_transform.origin
				var torque = relativePosition.cross(force)
				totalForce += torque
	state.apply_torque_impulse(totalTorque)
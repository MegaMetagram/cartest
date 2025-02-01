extends RigidBody3D

# Control parameters
var acceleration: float = 5.0
var steer_angle: float = 0.0
var max_steer_angle: float = 30.0
var turn_speed: float = 5.0
var friction: float = 0.1  # Friction value

# Debug toggles
var debugRaycasts: bool = true
var debugForces: bool = true
var debugTorques: bool = true

@onready var botLeftRC = $CollisionShape3D/botLeftRC
@onready var botRightRC = $CollisionShape3D/botRightRC
@onready var topLeftRC = $CollisionShape3D/topLeftRC
@onready var topRightRC = $CollisionShape3D/topRightRC

# List of raycasts
var raycast_nodes: Array

func _ready() -> void:
    raycast_nodes = [topLeftRC, topRightRC, botLeftRC, botRightRC]
    for raycast in raycast_nodes:
        raycast.car_body = self

func _physics_process(delta: float):
    var direction = Vector3.ZERO

    # Forward/backward input
    if Input.is_action_pressed("ui_up"):
        direction -= transform.basis.z * acceleration
    elif Input.is_action_pressed("ui_down"):
        direction += transform.basis.z * acceleration

    # Apply friction
    direction -= linear_velocity * friction

    # Steering input
    if Input.is_action_pressed("ui_left"):
        steer_angle -= turn_speed * delta
    elif Input.is_action_pressed("ui_right"):
        steer_angle += turn_speed * delta
    else:
        steer_angle = 0.0  # Reset when no input

    # Clamp the steering angle
    steer_angle = clamp(steer_angle, -max_steer_angle, max_steer_angle)

    # Apply movement
    apply_central_impulse(direction * delta)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    for raycast in raycast_nodes:
        raycast.apply_wheel_forces(state)
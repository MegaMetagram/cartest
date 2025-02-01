extends RayCast3D

# Hover parameters
var hover_height: float = 1.0
var spring_strength: float = 20.0
var damping: float = 50.0
var max_hover_force: float = 50.0
var gravity_strength: float = 9.8

# Reference to the car's body
var car_body: RigidBody3D

func _ready() -> void:
    # Ensure the raycast is enabled
    enabled = true

func apply_wheel_forces(state: PhysicsDirectBodyState3D) -> void:
    if is_colliding():
        var collision_point = get_collision_point()
        var distance = (global_transform.origin - collision_point).length()
        
        # Ensure we only apply force if the car is below hover height
        if distance > hover_height:
            return  # Skip applying force if we're above target height
        
        # Compression ratio (how much "spring" is compressed)
        var compression_ratio = clamp(1.0 - (distance / hover_height), 0.0, 1.0)
        var velocity = state.get_linear_velocity().y  # Get vertical velocity
        
        # Critical damping: Adjust damping dynamically based on mass
        var critical_damping = 2.0 * sqrt(spring_strength * car_body.mass)
        var damping_force = -critical_damping * velocity  # Slows down oscillations
        
        # Hover force calculation
        var hover_force = (compression_ratio * spring_strength) + damping_force
        
        # Subtract gravity so the car doesn't float infinitely
        hover_force -= gravity_strength * car_body.mass
        
        # Ensure force is only upwards and within limits
        hover_force = clamp(hover_force, 0.0, max_hover_force)

        if hover_force > 0:
            var force = Vector3(0, hover_force, 0)
            state.apply_force(force, global_transform.origin)

            # Torque tilt correction calculations
            var relative_position = global_transform.origin - car_body.global_transform.origin
            var torque = relative_position.cross(force)
            state.apply_torque(torque)
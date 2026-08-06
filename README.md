# b2arx_description

Reusable **visual** ROS description assets for the **Unitree B2 + ARX R5a** combined platform (`b2arx`).

Package layout follows the same product style as `fs150_description` and `mecanum_description`: meshes + visual URDF only. No controllers, Gazebo plugins, or hardcoded machine USB/serial topology.

## Package

| Item | Value |
|------|--------|
| ROS package | `b2arx_description` |
| Visual URDF | `urdf/b2arx_visual.urdf` |
| Robot name | `b2arx` |
| Meshes | `meshes/` (B2 body/legs + R5a arm links) |
| Debian package | `ros-jazzy-xgc2-b2arx-description` |

## Model content

- **B2**: links prefixed `b2_description*` (base, legs hip/thigh/calf/foot, sensors).
- **R5a arm**: links `R5a` / `R5a_link1`… and joints `R5a_joint1`….
- Mesh references use `package://b2arx_description/meshes/...` (ROS resource resolution).
- The URDF intentionally retains only links, joints, and visual geometry.
- `ASSET_SHA256SUMS` pins every installed mesh and the visual URDF.

## Build (ROS 2 Jazzy)

```bash
source /opt/ros/jazzy/setup.bash
colcon build --packages-select b2arx_description
source install/setup.bash
ros2 pkg prefix b2arx_description
```

## Install

```
sudo apt update
sudo apt install ros-jazzy-xgc2-b2arx-description
```

## Use in a visualizer or robot_state_publisher

Point the model path at the installed share file, for example:

```text
$(ros2 pkg prefix b2arx_description)/share/b2arx_description/urdf/b2arx_visual.urdf
```

Joint states and TF still come from your drivers; this package only supplies description assets.

## Provenance

Assets originated from the Thor onboard tree `workspaces/lerobot/opendoor/assets/b2arx` (combined B2 + ARX model used for teleop visualization). Productization renames the robot to `b2arx` and rewrites mesh paths to `package://` form.

## Non-goals

- No collision or inertial model; this is not a dynamics or planning model.
- No launch, RViz configuration, or integrated bringup.
- No hardcoded USB device IDs, CAN interfaces, or host IPs.
- No motor control or simulation plugins in this package.

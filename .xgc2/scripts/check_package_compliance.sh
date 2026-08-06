#!/usr/bin/env bash
set -euo pipefail

grep -q '^id: xgc2-ros-jazzy-b2arx-description$' .xgc2/product.yml
grep -q '^version: 0.1.0$' .xgc2/product.yml
grep -q '^kind: ros2-apt$' .xgc2/product.yml
grep -q '^  distro: jazzy$' .xgc2/product.yml
grep -q '^  distribution: noble$' .xgc2/product.yml
grep -q 'ros-jazzy-xgc2-b2arx-description' .xgc2/product.yml
grep -q '<name>b2arx_description</name>' package.xml
grep -q '<buildtool_depend>ament_cmake</buildtool_depend>' package.xml
grep -q '<build_type>ament_cmake</build_type>' package.xml
grep -q '^project(b2arx_description)$' CMakeLists.txt
test -f urdf/b2arx_visual.urdf
test -f meshes/base_link.dae
test -f meshes/link1.STL
test -f ASSET_SHA256SUMS
grep -q 'robot name="b2arx"' urdf/b2arx_visual.urdf
grep -q 'package://b2arx_description/meshes/' urdf/b2arx_visual.urdf
grep -q 'R5a_joint1' urdf/b2arx_visual.urdf
grep -q 'b2_description_FL_hip_joint' urdf/b2arx_visual.urdf

sha256sum --check ASSET_SHA256SUMS
python3 -m unittest discover -s test -v

# Description packages are visual assets only. They must not publish bringup,
# RViz, control, simulation, collision, or dynamics payloads.
if git ls-files | grep -E '^(launch|rviz|config|src|include)/'; then
  echo "non-visual payload is tracked" >&2
  exit 1
fi
if grep -ERi '<(collision|inertial|transmission|gazebo)|<plugin|ros_control|ros2_control|gazebo_ros' urdf package.xml CMakeLists.txt; then
  echo "non-visual URDF or runtime integration found" >&2
  exit 1
fi
# no relative mesh paths left
if grep -E 'filename="meshes/' urdf/b2arx_visual.urdf; then
  echo "relative mesh paths remain" >&2
  exit 1
fi
# product must not hardcode host USB/CAN
if grep -ERi 'enP2p1s0|2207:0019|slcan1|192\.168\.123' urdf package.xml CMakeLists.txt README.md; then
  echo "hardcoded machine topology found" >&2
  exit 1
fi

echo "Package compliance checks passed."

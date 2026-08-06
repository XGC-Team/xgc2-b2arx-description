#!/usr/bin/env bash
set -eo pipefail

source /opt/ros/jazzy/setup.bash
set -u

dpkg -s ros-jazzy-xgc2-b2arx-description >/dev/null
package_prefix="$(ros2 pkg prefix b2arx_description)"
test "${package_prefix}" = /opt/ros/jazzy
package_path="${package_prefix}/share/b2arx_description"
test -f "${package_path}/meshes/base_link.dae"
test -f "${package_path}/meshes/link8.STL"
test -f "${package_path}/urdf/b2arx_visual.urdf"
test -f "${package_path}/ASSET_SHA256SUMS"
test -f /opt/ros/jazzy/share/ament_index/resource_index/packages/b2arx_description

(
  cd "${package_path}"
  sha256sum --check ASSET_SHA256SUMS
)

python3 - "${package_path}/urdf/b2arx_visual.urdf" <<'PY'
import sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
assert root.attrib["name"] == "b2arx"
assert len(root.findall("link")) == 45
assert len(root.findall("joint")) == 44
for tag in ("collision", "inertial", "transmission", "gazebo", "plugin"):
    assert not root.findall(f".//{tag}"), tag
PY

echo "Installed package check passed."

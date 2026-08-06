#!/usr/bin/env python3
"""Guard b2arx combined visual URDF structure and mesh references."""

from __future__ import annotations

import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

PACKAGE = Path(__file__).resolve().parents[1]
URDF = PACKAGE / "urdf" / "b2arx_visual.urdf"
MESHES = PACKAGE / "meshes"


class B2ArxVisualAssetsTest(unittest.TestCase):
    def test_robot_name_and_mesh_package_uris(self) -> None:
        root = ET.parse(URDF).getroot()
        self.assertEqual(root.attrib.get("name"), "b2arx")
        meshes = root.findall(".//mesh")
        self.assertGreater(len(meshes), 10)
        for mesh in meshes:
            filename = mesh.attrib["filename"]
            self.assertTrue(
                filename.startswith("package://b2arx_description/meshes/"),
                msg=filename,
            )
            leaf = filename.rsplit("/", 1)[-1]
            self.assertTrue((MESHES / leaf).is_file(), msg=f"missing mesh {leaf}")

    def test_has_b2_and_r5a_kinematics(self) -> None:
        root = ET.parse(URDF).getroot()
        links = {e.attrib["name"] for e in root.findall("link")}
        joints = {e.attrib["name"] for e in root.findall("joint")}
        self.assertIn("b2_description", links)
        self.assertIn("R5a_link1", links)
        self.assertIn("b2_description_FL_hip_joint", joints)
        self.assertIn("R5a_joint1", joints)

    def test_required_mesh_files_exist(self) -> None:
        for name in (
            "base_link.dae",
            "FL_hip.dae",
            "FL_thigh.dae",
            "FL_calf.dae",
            "link1.STL",
            "link8.STL",
        ):
            self.assertTrue((MESHES / name).is_file(), msg=name)


if __name__ == "__main__":
    unittest.main()

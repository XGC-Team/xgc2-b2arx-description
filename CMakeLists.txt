cmake_minimum_required(VERSION 3.8)
project(b2arx_description)

find_package(ament_cmake REQUIRED)

install(DIRECTORY meshes urdf
  DESTINATION share/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_cmake_pytest REQUIRED)
  ament_add_pytest_test(b2arx_visual_assets test/test_visual_assets.py)
endif()

ament_package()

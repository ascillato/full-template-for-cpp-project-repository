cmake_minimum_required(VERSION 3.25)

project(embedded_linux_template_package_test LANGUAGES CXX)

find_package(EmbeddedLinuxTemplate CONFIG REQUIRED)

add_executable(embedded_linux_template_package_test src/example.cpp)
target_link_libraries(
    embedded_linux_template_package_test
    PRIVATE embedded_linux_template::core
)
target_compile_features(embedded_linux_template_package_test PRIVATE cxx_std_20)
set_target_properties(embedded_linux_template_package_test PROPERTIES CXX_EXTENSIONS OFF)

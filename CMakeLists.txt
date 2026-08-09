cmake_minimum_required(VERSION 3.25...4.4)

project(
    embedded_linux_template
    VERSION 0.1.0
    DESCRIPTION "A production-minded C++ template for embedded Linux applications"
    HOMEPAGE_URL "https://github.com/ascillato/full-template-for-cpp-project-repository"
    LANGUAGES CXX
)

# This project uses C++20 but not C++ modules. Disable CMake's automatic module
# dependency scanning so compile databases remain directly usable by clang-tidy.
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are not supported. Use a CMake preset or a separate build directory.")
endif()

include(CTest)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

option(EMBEDDED_LINUX_TEMPLATE_BUILD_APP "Build the sample command-line application" ON)
option(EMBEDDED_LINUX_TEMPLATE_BUILD_DOCS "Enable the documentation target" OFF)
option(EMBEDDED_LINUX_TEMPLATE_FETCH_DEPENDENCIES "Fetch missing test dependencies" ON)
option(EMBEDDED_LINUX_TEMPLATE_WARNINGS_AS_ERRORS "Treat project warnings as errors" OFF)
option(EMBEDDED_LINUX_TEMPLATE_ENABLE_HARDENING "Enable portable compiler and linker hardening" ON)
option(EMBEDDED_LINUX_TEMPLATE_ENABLE_IPO "Enable interprocedural optimization when supported" OFF)
option(EMBEDDED_LINUX_TEMPLATE_ENABLE_ASAN "Enable AddressSanitizer" OFF)
option(EMBEDDED_LINUX_TEMPLATE_ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" OFF)
option(EMBEDDED_LINUX_TEMPLATE_ENABLE_COVERAGE "Enable gcov-compatible coverage instrumentation" OFF)
option(EMBEDDED_LINUX_TEMPLATE_USE_CCACHE "Use ccache when it is available" OFF)

include(ProjectOptions)
embedded_linux_template_setup_project_options()

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.hpp.in"
    "${CMAKE_CURRENT_BINARY_DIR}/generated/embedded_linux_template/version.hpp"
    @ONLY
)

add_library(embedded_linux_template_core src/system_info.cpp)
add_library(embedded_linux_template::core ALIAS embedded_linux_template_core)
set_target_properties(
    embedded_linux_template_core
    PROPERTIES
        EXPORT_NAME core
        OUTPUT_NAME embedded_linux_template
        VERSION "${PROJECT_VERSION}"
        SOVERSION "${PROJECT_VERSION_MAJOR}"
        CXX_EXTENSIONS OFF
)
target_compile_features(embedded_linux_template_core PUBLIC cxx_std_20)
target_include_directories(
    embedded_linux_template_core
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
embedded_linux_template_apply_project_options(embedded_linux_template_core)

if(EMBEDDED_LINUX_TEMPLATE_BUILD_APP)
    add_subdirectory(app)
endif()

if(BUILD_TESTING)
    if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
        message(FATAL_ERROR "Cross-compiled tests require CMAKE_CROSSCOMPILING_EMULATOR. Disable BUILD_TESTING or provide an emulator.")
    endif()
    include(Dependencies)
    embedded_linux_template_setup_test_dependencies()
    add_subdirectory(tests)
endif()

if(EMBEDDED_LINUX_TEMPLATE_BUILD_DOCS)
    include(Documentation)
    embedded_linux_template_add_documentation()
endif()

install(
    TARGETS embedded_linux_template_core
    EXPORT EmbeddedLinuxTemplateTargets
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)
install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(
    FILES "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/${PROJECT_NAME}"
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/generated/embedded_linux_template/version.hpp"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/embedded_linux_template"
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/EmbeddedLinuxTemplateConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/EmbeddedLinuxTemplateConfig.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/EmbeddedLinuxTemplate"
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/EmbeddedLinuxTemplateConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/EmbeddedLinuxTemplateConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/EmbeddedLinuxTemplateConfigVersion.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/EmbeddedLinuxTemplate"
)
install(
    EXPORT EmbeddedLinuxTemplateTargets
    FILE EmbeddedLinuxTemplateTargets.cmake
    NAMESPACE embedded_linux_template::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/EmbeddedLinuxTemplate"
)

include(Packaging)

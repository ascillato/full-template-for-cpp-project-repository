import os
import re

from conan import ConanFile
from conan.errors import ConanException, ConanInvalidConfiguration
from conan.tools.build import check_min_cppstd, cross_building
from conan.tools.cmake import CMake, CMakeConfigDeps, CMakeToolchain, cmake_layout
from conan.tools.files import copy, load


class EmbeddedLinuxTemplateRecipe(ConanFile):
    name = "embedded-linux-template"
    package_type = "library"
    license = "MIT"
    url = "https://github.com/ascillato/full-template-for-cpp-project-repository"
    description = "A production-minded C++ template for embedded Linux applications"
    topics = ("cpp", "embedded-linux", "cmake", "template")
    required_conan_version = ">=2.25"
    exports = "version.txt"

    settings = "os", "arch", "compiler", "build_type"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "build_app": [True, False],
        "build_tests": [True, False],
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        "build_app": False,
        "build_tests": False,
    }

    exports_sources = (
        "CMakeLists.txt",
        "LICENSE",
        "version.txt",
        "app/*",
        "cmake/*",
        "cmake/toolchains/*",
        "include/*",
        "include/embedded_linux_template/*",
        "src/*",
        "tests/*",
    )

    def set_version(self):
        version_tag = load(self, os.path.join(self.recipe_folder, "version.txt")).strip()
        version_match = re.fullmatch(r"v([0-9]+\.[0-9]+\.[0-9]+)", version_tag)
        if version_match is None:
            raise ConanException(
                "version.txt must contain exactly one vMAJOR.MINOR.PATCH version"
            )
        self.version = version_match.group(1)

    def config_options(self):
        if self.settings.os == "Windows":
            self.options.rm_safe("fPIC")

    def configure(self):
        if self.options.get_safe("shared"):
            self.options.rm_safe("fPIC")

    def validate(self):
        if self.settings.os != "Linux":
            raise ConanInvalidConfiguration(
                "embedded-linux-template uses Linux kernel and procfs interfaces"
            )
        check_min_cppstd(self, "20")

    def build_requirements(self):
        if self.options.build_tests:
            self.test_requires("catch2/3.15.3")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        dependencies = CMakeConfigDeps(self)
        dependencies.generate()

        toolchain = CMakeToolchain(self)
        toolchain.cache_variables["BUILD_SHARED_LIBS"] = bool(self.options.shared)
        toolchain.cache_variables["BUILD_TESTING"] = bool(self.options.build_tests)
        toolchain.cache_variables["EMBEDDED_LINUX_TEMPLATE_BUILD_APP"] = bool(
            self.options.build_app
        )
        toolchain.cache_variables["EMBEDDED_LINUX_TEMPLATE_FETCH_DEPENDENCIES"] = False
        toolchain.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        if self.options.build_tests and not cross_building(self):
            cmake.test()

    def package(self):
        copy(self, "LICENSE", src=self.source_folder, dst=os.path.join(self.package_folder, "licenses"))
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["embedded_linux_template"]
        self.cpp_info.set_property("cmake_file_name", "EmbeddedLinuxTemplate")
        self.cpp_info.set_property("cmake_target_name", "embedded_linux_template::core")

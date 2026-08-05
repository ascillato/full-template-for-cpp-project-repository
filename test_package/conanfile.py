from conan import ConanFile
from conan.tools.build import can_run
from conan.tools.cmake import CMake, CMakeConfigDeps, CMakeToolchain, cmake_layout
import os


class EmbeddedLinuxTemplateTestPackage(ConanFile):
    settings = "os", "arch", "compiler", "build_type"
    test_type = "explicit"

    def requirements(self):
        self.requires(self.tested_reference_str)

    def layout(self):
        cmake_layout(self)

    def generate(self):
        dependencies = CMakeConfigDeps(self)
        dependencies.generate()
        toolchain = CMakeToolchain(self)
        toolchain.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def test(self):
        if can_run(self):
            executable = os.path.join(self.cpp.build.bindir, "embedded_linux_template_package_test")
            self.run(executable, env="conanrun")

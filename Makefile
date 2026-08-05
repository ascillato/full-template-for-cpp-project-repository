.DEFAULT_GOAL := help

CMAKE ?= cmake
CTEST ?= ctest
CPACK ?= cpack
PRESET ?= dev
JOBS ?=
DOCS_PYTHON ?= $(if $(wildcard .venv/bin/python),$(abspath .venv/bin/python),python3)

ifneq ($(wildcard .venv/bin),)
export PATH := $(abspath .venv/bin):$(PATH)
endif

BUILD_PARALLEL := --parallel $(JOBS)
TEST_PARALLEL := --parallel $(JOBS)

.PHONY: all bootstrap build check check-strict clean configure conan-install consumer-test coverage cppcheck \
	deploy docs docs-clean format format-check help install metrics package package-clean run sanitize \
	shellcheck spelling test tests-clean tidy verify cross-arm64 cross-armv7

all: build ## Configure and build the native development preset

bootstrap: ## Create a local Python environment with development and documentation tools
	python3 -m venv .venv
	.venv/bin/python -m pip install --upgrade pip
	.venv/bin/python -m pip install -r requirements-dev.txt -r docs/requirements.txt

configure: ## Configure PRESET (default: dev)
	$(CMAKE) --preset "$(PRESET)"

build: configure ## Build PRESET (default: dev)
	$(CMAKE) --build --preset "$(PRESET)" $(BUILD_PARALLEL)

run: build ## Build and run the native sample application
	./build/$(PRESET)/bin/embedded-linux-template

test: build ## Build and run all tests for PRESET
	$(CTEST) --preset "$(PRESET)" $(TEST_PARALLEL)

verify: format-check build test ## Run the fast host verification path

format-check: ## Check C++ formatting without changing files
	./scripts/format.sh --check

format: ## Apply clang-format to project C++ files
	./scripts/format.sh --fix

spelling: ## Spell-check source, documentation, and configuration
	./scripts/spelling.sh

tidy: ## Run clang-tidy against the analysis compile database
	$(MAKE) configure PRESET=analysis
	./scripts/run-clang-tidy.sh build/analysis

cppcheck: ## Run the independent cppcheck analyzer
	./scripts/run-cppcheck.sh

shellcheck: ## Check repository shell scripts
	shellcheck scripts/*.sh

check: format-check spelling tidy cppcheck shellcheck ## Run all formatting and static-analysis gates

check-strict: check ## Alias used when every quality tool must be present

sanitize: ## Build and test with AddressSanitizer and UBSan
	$(CMAKE) --preset sanitizers
	$(CMAKE) --build --preset sanitizers $(BUILD_PARALLEL)
	$(CTEST) --preset sanitizers $(TEST_PARALLEL)

coverage: ## Generate HTML/XML/JSON coverage reports under build/coverage
	./scripts/coverage.sh $(JOBS)

docs: ## Generate Doxygen API XML and Sphinx HTML documentation
	$(CMAKE) --preset docs -DPython3_EXECUTABLE="$(DOCS_PYTHON)"
	$(CMAKE) --build --preset docs --target docs $(BUILD_PARALLEL)

metrics: ## Print source metrics with cloc
	cloc --exclude-dir=build,.git,.venv,.cache .

package: ## Build and package the native release as a portable TGZ
	$(CMAKE) --preset release
	$(CMAKE) --build --preset release $(BUILD_PARALLEL)
	$(CPACK) --preset release

install: ## Stage-install the native release under build/release/stage
	$(MAKE) build PRESET=release
	$(CMAKE) --install build/release

consumer-test: install ## Verify the installed CMake package from a separate project
	$(CMAKE) -S test_package -B build/consumer -G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_PREFIX_PATH="$(CURDIR)/build/release/stage"
	$(CMAKE) --build build/consumer $(BUILD_PARALLEL)
	./build/consumer/embedded_linux_template_package_test

cross-arm64: ## Cross-build and package for GNU AArch64 Linux
	$(CMAKE) --preset arm64-release
	$(CMAKE) --build --preset arm64-release $(BUILD_PARALLEL)
	$(CPACK) --preset arm64-release

cross-armv7: ## Cross-build and package for GNU ARMv7 hard-float Linux
	$(CMAKE) --preset armv7-release
	$(CMAKE) --build --preset armv7-release $(BUILD_PARALLEL)
	$(CPACK) --preset armv7-release

deploy: ## Deploy BINARY to TARGET_HOST (explicit remote side effect)
	./scripts/deploy.sh

conan-install: ## Resolve optional dependencies with Conan's build/host model
	conan install . --output-folder=build/conan --build=missing \
		-s build_type=Debug -s compiler.cppstd=20 -o '&:build_tests=True'

tests-clean: ## Remove coverage and CTest result files
	$(CMAKE) -E remove_directory build/coverage
	$(CMAKE) -E remove_directory build/dev/Testing

docs-clean: ## Remove generated documentation
	$(CMAKE) -E remove_directory build/docs

package-clean: ## Remove generated package artifacts
	$(CMAKE) -E remove_directory build/release/packages
	$(CMAKE) -E remove_directory build/arm64-release/packages
	$(CMAKE) -E remove_directory build/armv7-release/packages

clean: ## Remove repository-local generated build outputs
	$(CMAKE) -E remove_directory build
	$(CMAKE) -E remove -f compile_commands.json

help: ## Show available commands
	@printf "Usage: make <target> [PRESET=dev] [JOBS=N]\n\nTargets:\n"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

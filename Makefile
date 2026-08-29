.DEFAULT_GOAL := help

CMAKE ?= cmake
CTEST ?= ctest
CPACK ?= cpack
PRESET ?= dev
JOBS ?=
DOCS_PYTHON ?= $(if $(wildcard .venv/bin/python),$(abspath .venv/bin/python),python3)

YELLOW := \033[1;33m
RED := \033[1;31m
GREEN := \033[1;32m
BLUE := \033[1;34m
RESET := \033[0m

ifneq ($(wildcard .venv/bin),)
export PATH := $(abspath .venv/bin):$(PATH)
endif

BUILD_PARALLEL := --parallel $(JOBS)
TEST_PARALLEL := --parallel $(JOBS)
CHECK_TARGETS := pre-commit-all tidy cppcheck

define run_with_status
	@ts="$$(date +"%Y-%m-%dT%H:%M:%S%z")"; \
	printf "$(YELLOW)\n\nStart $(1) at %s\n\n$(RESET)\n" "$$ts"; \
	if $(3); then \
		ts="$$(date +"%Y-%m-%dT%H:%M:%S%z")"; \
		printf "$(2)\n\n$(1) completed at %s\n\n$(RESET)\n" "$$ts"; \
	else \
		status=$$?; \
		ts="$$(date +"%Y-%m-%dT%H:%M:%S%z")"; \
		printf "$(RED)\n\nError running $(1). %s\n\n$(RESET)\n" "$$ts" >&2; \
		exit "$$status"; \
	fi
endef

.PHONY: all bootstrap build check check-strict clean configure conan-install consumer-test coverage cppcheck \
	deploy docs docs-clean format format-check help install metrics package package-clean run sanitize \
	pre-commit pre-commit-all setup-native shellcheck spelling test tests-clean tidy verify cross-arm64 cross-armv7

all: build ## Configure and build the native development preset

bootstrap: ## Create a local Python environment with development and documentation tools
	$(call run_with_status,Python development environment,$(YELLOW),python3 -m venv .venv && \
		.venv/bin/python -m pip install --upgrade pip && \
		.venv/bin/python -m pip install -r requirements-dev.txt -r docs/requirements.txt)

setup-native: ## Install the complete Debian/Ubuntu native development toolchain
	$(call run_with_status,Native development setup,$(YELLOW),./scripts/setup-native.sh)

configure: ## Configure PRESET (default: dev)
	$(call run_with_status,Configuration for $(PRESET),$(GREEN),$(CMAKE) --preset "$(PRESET)")

build: configure ## Build PRESET (default: dev)
	$(call run_with_status,Build for $(PRESET),$(GREEN),$(CMAKE) --build --preset "$(PRESET)" $(BUILD_PARALLEL))

run: build ## Build and run the native sample application
	$(call run_with_status,Sample application,$(YELLOW),./build/$(PRESET)/bin/embedded-linux-template)

test: build ## Build and run all tests for PRESET
	$(call run_with_status,Tests for $(PRESET),$(GREEN),$(CTEST) --preset "$(PRESET)" $(TEST_PARALLEL))

verify: format-check build test ## Run the fast host verification path

format-check: ## Check C++ formatting without changing files
	$(call run_with_status,C++ format check,$(BLUE),./scripts/format.sh --check)

format: ## Apply clang-format to project C++ files
	$(call run_with_status,C++ formatting,$(YELLOW),./scripts/format.sh --fix)

spelling: ## Spell-check source, documentation, and configuration
	$(call run_with_status,Spelling check,$(BLUE),./scripts/spelling.sh)

tidy: ## Run clang-tidy against the analysis compile database
	$(call run_with_status,Clang-tidy analysis,$(BLUE),$(CMAKE) --preset analysis && \
		./scripts/run-clang-tidy.sh build/analysis)

cppcheck: ## Run the independent cppcheck analyzer
	$(call run_with_status,Cppcheck analysis,$(BLUE),./scripts/run-cppcheck.sh)

shellcheck: ## Check repository shell scripts
	$(call run_with_status,ShellCheck analysis,$(BLUE),shellcheck scripts/*.sh)

pre-commit: ## Run pre-commit hooks against staged files
	$(call run_with_status,Staged-file pre-commit checks,$(BLUE),pre-commit run --show-diff-on-failure)

pre-commit-all: ## Run pre-commit hooks against all repository files
	$(call run_with_status,Repository-wide pre-commit checks,$(BLUE),pre-commit run --all-files --show-diff-on-failure)

check: ## Run all formatting and static-analysis gates
	$(call run_with_status,Quality checks,$(BLUE),$(MAKE) --no-print-directory $(CHECK_TARGETS))

check-strict: check ## Alias used when every quality tool must be present

sanitize: ## Build and test with AddressSanitizer and UBSan
	$(call run_with_status,Sanitizer build and tests,$(GREEN),$(CMAKE) --preset sanitizers && \
		$(CMAKE) --build --preset sanitizers $(BUILD_PARALLEL) && \
		$(CTEST) --preset sanitizers $(TEST_PARALLEL))

coverage: ## Generate HTML/XML/JSON coverage reports under build/coverage
	$(call run_with_status,Coverage build and reports,$(GREEN),./scripts/coverage.sh $(JOBS))

docs: ## Generate Doxygen API XML and Sphinx HTML documentation
	$(call run_with_status,Documentation build,$(BLUE),$(CMAKE) --preset docs \
		-DPython3_EXECUTABLE="$(DOCS_PYTHON)" && \
		$(CMAKE) --build --preset docs --target docs $(BUILD_PARALLEL))

metrics: ## Generate code metrics reports under build/metrics
	$(call run_with_status,Code metrics reports,$(BLUE),$(DOCS_PYTHON) scripts/generate-metrics.py \
		--output-directory build/metrics \
		--coverage-summary build/coverage/coverage-summary.json \
		--doxygen-xml build/docs/doxygen/xml)

package: ## Build and package the native release as a portable TGZ
	$(call run_with_status,Native release package,$(GREEN),$(CMAKE) --preset release && \
		$(CMAKE) --build --preset release $(BUILD_PARALLEL) && \
		$(CPACK) --preset release)

install: ## Stage-install the native release under build/release/stage
	$(call run_with_status,Staged native release install,$(GREEN),$(CMAKE) --preset release && \
		$(CMAKE) --build --preset release $(BUILD_PARALLEL) && \
		$(CMAKE) --install build/release)

consumer-test: install ## Verify the installed CMake package from a separate project
	$(call run_with_status,Installed package consumer test,$(GREEN),$(CMAKE) \
		-S test_package -B build/consumer -G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_PREFIX_PATH="$(CURDIR)/build/release/stage" && \
		$(CMAKE) --build build/consumer $(BUILD_PARALLEL) && \
		./build/consumer/embedded_linux_template_package_test)

cross-arm64: ## Cross-build and package for GNU AArch64 Linux
	$(call run_with_status,AArch64 release build and package,$(GREEN),$(CMAKE) --preset arm64-release && \
		$(CMAKE) --build --preset arm64-release $(BUILD_PARALLEL) && \
		$(CPACK) --preset arm64-release)

cross-armv7: ## Cross-build and package for GNU ARMv7 hard-float Linux
	$(call run_with_status,ARMv7 release build and package,$(GREEN),$(CMAKE) --preset armv7-release && \
		$(CMAKE) --build --preset armv7-release $(BUILD_PARALLEL) && \
		$(CPACK) --preset armv7-release)

deploy: ## Deploy BINARY to TARGET_HOST (explicit remote side effect)
	$(call run_with_status,Deployment,$(YELLOW),./scripts/deploy.sh)

conan-install: ## Resolve optional dependencies with Conan's build/host model
	$(call run_with_status,Conan dependency installation,$(YELLOW),conan install . \
		--output-folder=build/conan --build=missing \
		-s build_type=Debug -s compiler.cppstd=20 -o '&:build_tests=True')

tests-clean: ## Remove coverage and CTest result files
	$(call run_with_status,Test output cleanup,$(YELLOW),$(CMAKE) -E remove_directory build/coverage && \
		$(CMAKE) -E remove_directory build/dev/Testing)

docs-clean: ## Remove generated documentation
	$(call run_with_status,Documentation output cleanup,$(YELLOW),$(CMAKE) -E remove_directory build/docs && \
		$(CMAKE) -E remove_directory build/metrics)

package-clean: ## Remove generated package artifacts
	$(call run_with_status,Package output cleanup,$(YELLOW),$(CMAKE) -E remove_directory build/release/packages && \
		$(CMAKE) -E remove_directory build/arm64-release/packages && \
		$(CMAKE) -E remove_directory build/armv7-release/packages)

clean: ## Remove repository-local generated build outputs
	$(call run_with_status,Generated build output cleanup,$(YELLOW),$(CMAKE) -E remove_directory build && \
		$(CMAKE) -E remove -f compile_commands.json)

help: ## Show available commands
	@printf "Usage: make <target> [PRESET=dev] [JOBS=N]\n\nTargets:\n"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

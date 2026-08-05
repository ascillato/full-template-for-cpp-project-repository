add_executable(embedded_linux_template_tests system_info_test.cpp)
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/tmp")
target_link_libraries(
    embedded_linux_template_tests
    PRIVATE embedded_linux_template::core Catch2::Catch2WithMain
)
embedded_linux_template_apply_project_options(embedded_linux_template_tests)

include(Catch)
catch_discover_tests(
    embedded_linux_template_tests
    DISCOVERY_MODE PRE_TEST
    PROPERTIES LABELS "unit"
)

if(TARGET embedded-linux-template)
    add_test(NAME embedded_linux_template.cli_help COMMAND embedded-linux-template --help)
    set_tests_properties(
        embedded_linux_template.cli_help
        PROPERTIES PASS_REGULAR_EXPRESSION "Usage:" LABELS "integration"
    )
    add_test(NAME embedded_linux_template.cli_version COMMAND embedded-linux-template --version)
    set_tests_properties(
        embedded_linux_template.cli_version
        PROPERTIES PASS_REGULAR_EXPRESSION "${PROJECT_VERSION}" LABELS "integration"
    )
    add_test(NAME embedded_linux_template.cli_invalid_option COMMAND embedded-linux-template --invalid)
    set_tests_properties(
        embedded_linux_template.cli_invalid_option
        PROPERTIES WILL_FAIL TRUE LABELS "integration"
    )
    add_test(NAME embedded_linux_template.cli_text COMMAND embedded-linux-template)
    set_tests_properties(
        embedded_linux_template.cli_text
        PROPERTIES PASS_REGULAR_EXPRESSION "hostname:" LABELS "integration"
    )
    add_test(NAME embedded_linux_template.cli_json COMMAND embedded-linux-template --json)
    set_tests_properties(
        embedded_linux_template.cli_json
        PROPERTIES PASS_REGULAR_EXPRESSION "hostname" LABELS "integration"
    )
endif()

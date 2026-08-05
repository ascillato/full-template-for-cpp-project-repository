include_guard(GLOBAL)

function(embedded_linux_template_add_documentation)
    find_package(Doxygen 1.9 REQUIRED COMPONENTS dot)
    find_package(Python3 3.10 REQUIRED COMPONENTS Interpreter)

    set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/doxygen")
    configure_file(
        "${PROJECT_SOURCE_DIR}/docs/Doxyfile.in"
        "${CMAKE_BINARY_DIR}/docs/Doxyfile"
        @ONLY
    )

    # This target intentionally runs every time: Doxygen recursively reads source and
    # Markdown trees, including newly added files that CMake has not seen before.
    add_custom_target(
        doxygen
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${DOXYGEN_OUTPUT_DIRECTORY}"
        COMMAND "${DOXYGEN_EXECUTABLE}" "${CMAKE_BINARY_DIR}/docs/Doxyfile"
        BYPRODUCTS "${DOXYGEN_OUTPUT_DIRECTORY}/xml/index.xml"
        DEPENDS
            embedded_linux_template_core
            "${PROJECT_SOURCE_DIR}/docs/Doxyfile.in"
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        COMMENT "Generating Doxygen XML"
        VERBATIM
    )

    add_custom_target(
        docs
        COMMAND
            "${CMAKE_COMMAND}" -E env
            "DOXYGEN_XML_DIR=${DOXYGEN_OUTPUT_DIRECTORY}/xml"
            "PROJECT_VERSION=${PROJECT_VERSION}"
            "${Python3_EXECUTABLE}" -m sphinx -W --keep-going -b html
            "${PROJECT_SOURCE_DIR}/docs" "${CMAKE_BINARY_DIR}/html"
        DEPENDS doxygen
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        COMMENT "Generating Sphinx HTML documentation"
        VERBATIM
    )
endfunction()

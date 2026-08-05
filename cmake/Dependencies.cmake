include_guard(GLOBAL)

include(FetchContent)

function(embedded_linux_template_setup_test_dependencies)
    find_package(Catch2 3.15 CONFIG QUIET)
    if(Catch2_FOUND)
        return()
    endif()

    if(NOT EMBEDDED_LINUX_TEMPLATE_FETCH_DEPENDENCIES)
        message(FATAL_ERROR "Catch2 3.15+ was not found. Install it with Conan or enable EMBEDDED_LINUX_TEMPLATE_FETCH_DEPENDENCIES.")
    endif()

    set(CATCH_BUILD_TESTING OFF CACHE BOOL "" FORCE)
    set(CATCH_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(CATCH_BUILD_EXTRA_TESTS OFF CACHE BOOL "" FORCE)
    set(CATCH_BUILD_FUZZERS OFF CACHE BOOL "" FORCE)
    set(CATCH_INSTALL_DOCS OFF CACHE BOOL "" FORCE)
    set(CATCH_INSTALL_EXTRAS OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG 8b08d4d79514f45f7e4ce2a607ac9c94e920d1bb
        GIT_SHALLOW FALSE
        GIT_PROGRESS TRUE
    )
    FetchContent_MakeAvailable(Catch2)
    list(APPEND CMAKE_MODULE_PATH "${catch2_SOURCE_DIR}/extras")
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endfunction()

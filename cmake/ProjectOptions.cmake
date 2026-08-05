include_guard(GLOBAL)

include(CheckIPOSupported)

function(embedded_linux_template_setup_project_options)
    add_library(embedded_linux_template_project_options INTERFACE)
    add_library(embedded_linux_template_project_warnings INTERFACE)

    target_compile_options(
        embedded_linux_template_project_warnings
        INTERFACE
            "$<$<CXX_COMPILER_ID:GNU>:-Wall;-Wextra;-Wpedantic;-Wconversion;-Wsign-conversion;-Wshadow;-Wformat=2;-Wundef;-Wcast-align;-Wcast-qual;-Wdouble-promotion;-Wduplicated-branches;-Wduplicated-cond;-Wlogical-op;-Wmissing-declarations;-Wnon-virtual-dtor;-Wnull-dereference;-Wold-style-cast;-Woverloaded-virtual;-Wuseless-cast;-Wdate-time;-Werror=return-type>"
            "$<$<CXX_COMPILER_ID:Clang,AppleClang>:-Wall;-Wextra;-Wpedantic;-Wconversion;-Wsign-conversion;-Wshadow;-Wformat=2;-Wundef;-Wcast-align;-Wcast-qual;-Wdouble-promotion;-Wimplicit-fallthrough;-Wmissing-declarations;-Wnon-virtual-dtor;-Wnull-dereference;-Wold-style-cast;-Woverloaded-virtual;-Wdate-time;-Werror=return-type>"
            "$<$<CXX_COMPILER_ID:MSVC>:/W4;/permissive-;/w14242;/w14254;/w14263;/w14265;/w14287;/w14296;/w14311;/w14545;/w14546;/w14547;/w14549;/w14555;/w14619;/w14640;/w14826;/w14905;/w14906;/w14928>"
    )

    if(EMBEDDED_LINUX_TEMPLATE_WARNINGS_AS_ERRORS)
        target_compile_options(
            embedded_linux_template_project_warnings
            INTERFACE
                "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Werror>"
                "$<$<CXX_COMPILER_ID:MSVC>:/WX>"
        )
    endif()

    if(EMBEDDED_LINUX_TEMPLATE_ENABLE_HARDENING AND UNIX AND NOT APPLE)
        target_compile_options(
            embedded_linux_template_project_options
            INTERFACE
                "$<$<CXX_COMPILER_ID:GNU,Clang>:-fstack-protector-strong>"
        )
        target_compile_definitions(
            embedded_linux_template_project_options
            INTERFACE
                "$<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:GNU,Clang>>:_FORTIFY_SOURCE=2>"
        )
        target_link_options(
            embedded_linux_template_project_options
            INTERFACE
                "$<$<CXX_COMPILER_ID:GNU,Clang>:-Wl,-z,relro,-z,now;-Wl,-z,noexecstack>"
        )
    endif()

    if(EMBEDDED_LINUX_TEMPLATE_ENABLE_ASAN OR EMBEDDED_LINUX_TEMPLATE_ENABLE_UBSAN)
        if(MSVC)
            message(FATAL_ERROR "The sanitizer preset currently supports GCC and Clang only.")
        endif()
        if(CMAKE_CROSSCOMPILING)
            message(FATAL_ERROR "Sanitizers are intended for native host builds in this template.")
        endif()

        set(_sanitizers "")
        if(EMBEDDED_LINUX_TEMPLATE_ENABLE_ASAN)
            list(APPEND _sanitizers address)
        endif()
        if(EMBEDDED_LINUX_TEMPLATE_ENABLE_UBSAN)
            list(APPEND _sanitizers undefined)
        endif()
        list(JOIN _sanitizers "," _sanitizer_list)
        target_compile_options(
            embedded_linux_template_project_options
            INTERFACE "-fsanitize=${_sanitizer_list}" -fno-omit-frame-pointer
        )
        target_link_options(
            embedded_linux_template_project_options
            INTERFACE "-fsanitize=${_sanitizer_list}" -fno-omit-frame-pointer
        )
    endif()

    if(EMBEDDED_LINUX_TEMPLATE_ENABLE_COVERAGE)
        if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            message(FATAL_ERROR "The gcovr coverage preset requires GCC.")
        endif()
        if(CMAKE_CROSSCOMPILING)
            message(FATAL_ERROR "Coverage is intended for native host builds in this template.")
        endif()
        target_compile_options(embedded_linux_template_project_options INTERFACE --coverage -O0 -g)
        target_link_options(embedded_linux_template_project_options INTERFACE --coverage)
    endif()

    if(EMBEDDED_LINUX_TEMPLATE_USE_CCACHE)
        find_program(_ccache_program ccache)
        if(_ccache_program)
            set(CMAKE_CXX_COMPILER_LAUNCHER "${_ccache_program}" CACHE FILEPATH "C++ compiler launcher" FORCE)
        endif()
    endif()

    if(EMBEDDED_LINUX_TEMPLATE_ENABLE_IPO)
        check_ipo_supported(RESULT _ipo_supported OUTPUT _ipo_error LANGUAGES CXX)
        if(NOT _ipo_supported)
            message(FATAL_ERROR "IPO/LTO is not supported: ${_ipo_error}")
        endif()
    endif()
endfunction()

function(embedded_linux_template_apply_project_options target_name)
    target_link_libraries(
        "${target_name}"
        PRIVATE
            "$<BUILD_INTERFACE:embedded_linux_template_project_options>"
            "$<BUILD_INTERFACE:embedded_linux_template_project_warnings>"
    )
    set_target_properties("${target_name}" PROPERTIES CXX_EXTENSIONS OFF)
    if(EMBEDDED_LINUX_TEMPLATE_ENABLE_IPO)
        set_property(TARGET "${target_name}" PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
    endif()
endfunction()

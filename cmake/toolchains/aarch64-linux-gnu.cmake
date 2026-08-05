set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

find_program(CMAKE_C_COMPILER NAMES aarch64-linux-gnu-gcc REQUIRED)
find_program(CMAKE_CXX_COMPILER NAMES aarch64-linux-gnu-g++ REQUIRED)

if(DEFINED ENV{EMBEDDED_SYSROOT} AND NOT "$ENV{EMBEDDED_SYSROOT}" STREQUAL "")
    file(REAL_PATH "$ENV{EMBEDDED_SYSROOT}" _embedded_sysroot EXPAND_TILDE)
    if(NOT IS_DIRECTORY "${_embedded_sysroot}")
        message(FATAL_ERROR "EMBEDDED_SYSROOT does not name a directory: ${_embedded_sysroot}")
    endif()
    set(CMAKE_SYSROOT "${_embedded_sysroot}" CACHE PATH "Target sysroot")
    set(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}")
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

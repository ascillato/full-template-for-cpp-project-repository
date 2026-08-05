add_executable(embedded-linux-template main.cpp)
target_link_libraries(embedded-linux-template PRIVATE embedded_linux_template::core)
embedded_linux_template_apply_project_options(embedded-linux-template)

if(UNIX AND NOT APPLE)
    set_target_properties(
        embedded-linux-template
        PROPERTIES INSTALL_RPATH "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
    )
endif()

install(TARGETS embedded-linux-template RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

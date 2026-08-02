# Define the Minimum CMake Version
cmake_minimum_required(VERSION 3.16)

# Set Module Name
set(MODULE_NAME "mod-archipelago")

# Collect all C++ source files for the module
set(MODULE_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/mod_archipelago.cpp"
)

# Call standard AzerothCore module setup helper if available,
# otherwise fall back to standard library target creation.
if(COMMAND ac_add_module)
    ac_add_module(${MODULE_NAME} STATIC SOURCES ${MODULE_SOURCES})
else()
    add_library(${MODULE_NAME} STATIC ${MODULE_SOURCES})
    target_link_libraries(${MODULE_NAME} PRIVATE acore-game)
endif()

message(STATUS "AzerothCore: Added module '${MODULE_NAME}'")

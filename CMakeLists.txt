cmake_minimum_required(VERSION 3.16.3)
project(CLP_CPP LANGUAGES CXX)

set(CLP_COMMONS_SOVERSION 0)

# When clp-cpp is included as subproject (i.e. using add_subdirectory(clp-cpp)) in the source tree
# of a project that uses it, install rules are disabled.
if(NOT CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
  option(CLP_CPP_ENABLE_INSTALL "Enable install rule" OFF)
else()
  option(CLP_CPP_ENABLE_INSTALL "Enable install rule" ON)
endif()

# Add clp-cpp project directory to include path lists
list(APPEND CLP_CPP_COMMON_INCLUDE_DIRS
  ${PROJECT_SOURCE_DIR}
  ${PROJECT_SOURCE_DIR}/submodules
)

# Import CMake helper functions
list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_CURRENT_LIST_DIR}/CMake
)
include(ClpCppHelpers)

add_subdirectory(clp)

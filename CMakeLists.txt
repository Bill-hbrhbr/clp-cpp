cmake_minimum_required(VERSION 3.16.3)
project(CLP_CPP LANGUAGES CXX)

# Static everything for now
option(BUILD_SHARED_LIBS OFF)
option(CLP_CPP_USE_STATIC_LIBS ON)
unset(CLP_CPP_SOVERSION)

# TODO: agree on these naming conventions
set(CLP_CPP_VERSION "0.0.1" CACHE STRING "Project version.")
set(VERSIONED_PROJECT_NAME "clp-cpp-${CLP_CPP_VERSION}" CACHE STRING "Project name with version." )
set(TARGET_EXPORT_NAME "clp-cpp-targets" CACHE STRING "Project target export name.")
set(PROJECT_CONFIG_NAME "clp-cpp-config" CACHE STRING "Project config name.")
set(PROJECT_CONFIG_VERSION_NAME "clp-cpp-config-version" CACHE STRING "Project config version name.")

# All paths are relative to CMAKE_INSTALL_PREFIX
set(CMAKE_INSTALL_LIBDIR lib)
set(CMAKE_INSTALL_BINDIR bin)
set(CMAKE_INSTALL_INCLUDEDIR include/${VERSIONED_PROJECT_NAME})
set(CMAKE_INSTALL_PKGCONFDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${VERSIONED_PROJECT_NAME})

# When clp-cpp is included as subproject (i.e. using add_subdirectory(clp-cpp)) in the source tree
# of a project that uses it, install rules are disabled.
if(NOT CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
  option(CLP_CPP_ENABLE_INSTALL "Enable install rule" OFF)
else()
  option(CLP_CPP_ENABLE_INSTALL "Enable install rule" ON)
endif()

list(APPEND CLP_CPP_BUILD_INCLUDE_DIRS
  ${PROJECT_SOURCE_DIR}
  ${PROJECT_SOURCE_DIR}/submodules
)

if (CLP_CPP_ENABLE_INSTALL)
    list(APPEND CLP_CPP_INSTALL_INCLUDE_DIRS ${CMAKE_INSTALL_INCLUDEDIR})
else()
    list(APPEND CLP_CPP_INSTALL_INCLUDE_DIRS ${CLP_CPP_BUILD_INCLUDE_DIRS})
endif()

# Import CMake helper functions
list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_CURRENT_LIST_DIR}/CMake
)
include(ClpCppHelpers)

add_subdirectory(clp)

if (CLP_CPP_ENABLE_INSTALL)
  include(CMakePackageConfigHelpers)

  install(EXPORT ${TARGET_EXPORT_NAME}
    FILE ${TARGET_EXPORT_NAME}.cmake
    NAMESPACE clp::
    DESTINATION ${CMAKE_INSTALL_PKGCONFDIR}
  )
  configure_package_config_file(${CMAKE_CURRENT_LIST_DIR}/CMake/${PROJECT_CONFIG_NAME}.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG_NAME}.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_PKGCONFDIR}
  )
  write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG_VERSION_NAME}.cmake"
    VERSION ${CLP_CPP_VERSION}
    COMPATIBILITY AnyNewerVersion
  )
  install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG_NAME}.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_CONFIG_VERSION_NAME}.cmake"
    DESTINATION ${CMAKE_INSTALL_PKGCONFDIR}
  )
endif()

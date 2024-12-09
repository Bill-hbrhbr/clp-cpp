# check_if_header_only_library()
#
# Check if a library is header-only.
function(check_if_header_only_library source_list_var is_header_only_var)
  set(local_source_list "${${source_list_var}}")
  foreach(src_file IN LISTS local_source_list)
    if(${src_file} MATCHES ".*\\.(h|inc)")
      list(REMOVE_ITEM local_source_list "${src_file}")
    endif()
  endforeach()

  if(local_source_list STREQUAL "")
    set(${is_header_only_var} 1 PARENT_SCOPE)
  else()
    set(${is_header_only_var} 0 PARENT_SCOPE)
  endif()
endfunction()

# clp_cpp_library()
#
# CMake function to imitate Bazel's cc_library rule.
#
# Parameters:
# NAME: name of target (see Note)
# HDRS: List of public header files for the library
# SRCS: List of source files for the library
# DEPS: List of other libraries to be linked in to the binary targets
# COPTS: List of private compile options
# DEFINES: List of public defines
# LINKOPTS: List of link options
# PUBLIC: Add this so that this library will be exported under clp::
# PRIVATE: Add this to make the library internal to clp-cpp
# TESTONLY: Add this for unit test targets
#
# Note:
# When included as a subdirectory, clp_cpp_library will always create a library named clp_${NAME},
# and alias target clp::${NAME}. The clp:: form should always be used to reduce namespace pollution.
function(clp_cpp_library)
  set(options PUBLIC PRIVATE TESTONLY)
  set(oneValueArgs NAME)
  set(multiValueArgs HDRS SRCS COPTS DEFINES LINKOPTS DEPS)
  cmake_parse_arguments(arg_clp_cpp_lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(CLP_CPP_ENABLE_INSTALL)
    set(_INSTALL_LIB_NAME "${arg_clp_cpp_lib_NAME}")
  else()
    set(_INSTALL_LIB_NAME "clp_${arg_clp_cpp_lib_NAME}")
  endif()

  check_if_header_only_library(arg_clp_cpp_lib_SRCS _CLP_CPP_LIB_IS_INTERFACE)

  if (_CLP_CPP_LIB_IS_INTERFACE)
    add_library(${_INSTALL_LIB_NAME} INTERFACE)
    add_library(clp::${arg_clp_cpp_lib_NAME} ALIAS ${_INSTALL_LIB_NAME})
    target_include_directories(${_INSTALL_LIB_NAME} INTERFACE ${CLP_CPP_COMMON_INCLUDE_DIRS})
    target_compile_features(${_INSTALL_LIB_NAME} INTERFACE cxx_std_20)
  else()
    add_library(${_INSTALL_LIB_NAME} STATIC)
    add_library(clp::${arg_clp_cpp_lib_NAME} ALIAS ${_INSTALL_LIB_NAME})
    target_sources(${_INSTALL_LIB_NAME} PRIVATE ${arg_clp_cpp_lib_SRCS} ${arg_clp_cpp_lib_HDRS})

    target_include_directories(${_INSTALL_LIB_NAME} PUBLIC ${CLP_CPP_COMMON_INCLUDE_DIRS})
    target_compile_features(${_INSTALL_LIB_NAME} PUBLIC cxx_std_20)
    target_link_libraries(${_INSTALL_LIB_NAME}
      PUBLIC  ${arg_clp_cpp_lib_DEPS}
      PRIVATE ${arg_clp_cpp_lib_LINKOPTS}
    )
  endif()

endfunction()

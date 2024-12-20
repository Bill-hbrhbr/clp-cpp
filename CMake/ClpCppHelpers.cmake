# check_if_header_only_library()
#
# @param source_list_var The list of source files that a target library uses
# @param is_header_only_var Returns whether the target library only contains header files
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
    set(_TARGET_LIB_NAME "${arg_clp_cpp_lib_NAME}")
  else()
    set(_TARGET_LIB_NAME "clp_${arg_clp_cpp_lib_NAME}")
  endif()

  check_if_header_only_library(arg_clp_cpp_lib_SRCS _CLP_CPP_LIB_IS_INTERFACE)

  if (_CLP_CPP_LIB_IS_INTERFACE)
    add_library(${_TARGET_LIB_NAME} INTERFACE)
    target_include_directories(${_TARGET_LIB_NAME} INTERFACE
      "$<BUILD_INTERFACE:${CLP_CPP_BUILD_INCLUDE_DIRS}>"
      "$<INSTALL_INTERFACE:${CLP_CPP_INSTALL_INCLUDE_DIRS}>"
    )
    target_compile_features(${_TARGET_LIB_NAME} INTERFACE cxx_std_20)
  else()
    add_library(${_TARGET_LIB_NAME} STATIC)
    target_sources(${_TARGET_LIB_NAME} PRIVATE ${arg_clp_cpp_lib_SRCS} ${arg_clp_cpp_lib_HDRS})
    target_include_directories(${_TARGET_LIB_NAME} PUBLIC
      "$<BUILD_INTERFACE:${CLP_CPP_BUILD_INCLUDE_DIRS}>"
      "$<INSTALL_INTERFACE:${CLP_CPP_INSTALL_INCLUDE_DIRS}>"
    )
    target_compile_features(${_TARGET_LIB_NAME} PUBLIC cxx_std_20)
    set_property(TARGET ${_TARGET_LIB_NAME} PROPERTY OUTPUT_NAME "clp_${arg_clp_cpp_lib_NAME}")
  endif()

  target_link_libraries(${_TARGET_LIB_NAME}
    PUBLIC  ${arg_clp_cpp_lib_DEPS}
    PRIVATE ${arg_clp_cpp_lib_LINKOPTS}
  )

  add_library(clp::${arg_clp_cpp_lib_NAME} ALIAS ${_TARGET_LIB_NAME})

  if (CLP_CPP_ENABLE_INSTALL)
    install(
      FILES ${arg_clp_cpp_lib_HDRS}
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/clp/${arg_clp_cpp_lib_NAME}
    )
    install(TARGETS ${_TARGET_LIB_NAME}
        EXPORT ${TARGET_EXPORT_NAME}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
	)
  endif()

endfunction()

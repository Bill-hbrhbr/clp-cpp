project(clp_error_handling LANGUAGES CXX)

add_library(clp_error_handling INTERFACE)
add_library(clp::error_handling ALIAS clp_error_handling)

target_include_directories(clp_error_handling INTERFACE ${CLP_CPP_COMMON_INCLUDE_DIRS})
target_compile_features(clp_error_handling INTERFACE cxx_std_20)

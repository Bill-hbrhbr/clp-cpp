project(clp_array LANGUAGES CXX)

add_library(clp_array INTERFACE)
add_library(clp::array ALIAS clp_array)

target_include_directories(clp_array INTERFACE ${CLP_CPP_COMMON_INCLUDE_DIRS})
target_compile_features(clp_array INTERFACE cxx_std_20)

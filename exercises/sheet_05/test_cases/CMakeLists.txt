cmake_minimum_required(VERSION 3.11)
project(pod_sheet05_testcases)

set_property(GLOBAL PROPERTY C_STANDARD 11)

if(MSVC)
  add_compile_options(/W4 /WX)
else()
  add_compile_options(-Wall -Wextra -Wpedantic -Werror -Wno-unknown-pragmas)
endif()

add_executable(mmul mmul/mmul.c)

add_executable(delannoy delannoy/delannoy.c)

add_executable(nbody nbody/nbody.c)
target_link_libraries(nbody m)

add_executable(qap qap/qap.c)

file(GLOB_RECURSE NPB_BT_SRC CONFIGURE_DEPENDS npb_bt_w/*.c)
add_executable(npb_bt_w ${NPB_BT_SRC})
target_compile_options(npb_bt_w PRIVATE -Wno-unused-parameter -Wno-unused-but-set-variable)
target_link_libraries(npb_bt_w m)

file(GLOB_RECURSE SSCA2_SRC CONFIGURE_DEPENDS ssca2/*.c ssca2/sprng2.0/*.c)
add_executable(ssca2 ${SSCA2_SRC})
target_compile_definitions(ssca2 PRIVATE -DLittleEndian -DAdd__)
target_include_directories(ssca2 PRIVATE ssca2/sprng2.0/include)
target_compile_options(ssca2 PRIVATE -Wno-error)
target_link_libraries(ssca2 m)

cmake_minimum_required(VERSION 3.20)
project(BFDll C ASM_MASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

if(NOT MSVC)
    message(FATAL_ERROR "BFDll currently requires MSVC (ml64 + link.exe)")
endif()

find_package(Python3 REQUIRED COMPONENTS Interpreter)

include("${CMAKE_SOURCE_DIR}/cmake/bfdll.cmake")

add_bfdll(bfdll)

add_executable(test_host host/test_host.c)
set_target_properties(test_host PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

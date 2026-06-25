function(add_bfdll TARGET)
    set(BF_PROGRAMS_DIR "${CMAKE_SOURCE_DIR}/src/programs")
    set(BF_GEN_ASM "${CMAKE_BINARY_DIR}/gen/bf_programs.asm")

    file(GLOB BF_SOURCES CONFIGURE_DEPENDS "${BF_PROGRAMS_DIR}/*.bf")
    if(NOT BF_SOURCES)
        message(FATAL_ERROR "No .bf programs found in ${BF_PROGRAMS_DIR}")
    endif()

    add_custom_command(
        OUTPUT "${BF_GEN_ASM}"
        COMMAND ${Python3_EXECUTABLE} "${CMAKE_SOURCE_DIR}/tools/bf2asm.py"
                ${BF_SOURCES}
                -o "${BF_GEN_ASM}"
        DEPENDS ${BF_SOURCES} "${CMAKE_SOURCE_DIR}/tools/bf2asm.py"
        COMMENT "Generating MASM from Brainfuck programs"
        VERBATIM
    )

    set(BF_ASM_OBJ "${CMAKE_BINARY_DIR}/gen/bf_programs.obj")
    add_custom_command(
        OUTPUT "${BF_ASM_OBJ}"
        COMMAND "${CMAKE_ASM_MASM_COMPILER}" /c /Fo "${BF_ASM_OBJ}" "${BF_GEN_ASM}"
        DEPENDS "${BF_GEN_ASM}"
        COMMENT "Assembling bf_programs.asm"
        VERBATIM
    )

    add_library(${TARGET} SHARED
        src/vm/bf_vm.c
        src/runtime/bf_io.c
        src/runtime/bf_stub.c
        src/runtime/dllmain.c
        "${BF_ASM_OBJ}"
    )

    target_include_directories(${TARGET} PRIVATE
        "${CMAKE_SOURCE_DIR}/src"
        "${CMAKE_SOURCE_DIR}/src/vm"
        "${CMAKE_SOURCE_DIR}/src/runtime"
    )

    target_compile_definitions(${TARGET} PRIVATE BFDLL_EXPORTS)

    set_target_properties(${TARGET} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    )

    target_link_options(${TARGET} PRIVATE
        "/DEF:${CMAKE_SOURCE_DIR}/exports/bfdll.def"
        "/SUBSYSTEM:WINDOWS"
        "/MERGE:bf_text=.text"
        "/INCLUDE:BF_Prog_Hello"
        "/INCLUDE:BF_Prog_HelloWorld"
        "/INCLUDE:BF_Prog_Add"
    )
endfunction()

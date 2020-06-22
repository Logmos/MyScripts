macro( CLANGFORMAT )
    cmake_parse_arguments(CLANGFORMAT "" "" "NAME;SWITCHES;SOURCES" ${ARGN} )

    if (CLANGFORMAT_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "CLANGFORMATS Unknown argument: ${CLANGFORMAT_UNPARSED_ARGUMENTS}")
    endif()

    find_program(CLANGFORMAT_EXECUTABLE NAMES clang-format PATHS
        "${CLANGFORMAT_PATH}")
    if(NOT CLANGFORMAT_EXECUTABLE)
        message(FATAL_ERROR "clang-format not found!")
    endif()

    set(TARGET_NAME clang-format_${CLANGFORMAT_NAME})
    add_custom_target(${TARGET_NAME}
        COMMAND clang-format
        ${CLANGFORMAT_SWITCHES}
        ${CLANGFORMAT_SOURCES}
        WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT
        "Running ${TARGET_NAME} for ${CLANGFORMAT_SOURCES}"
        )
    add_dependencies(clangFormat ${TARGET_NAME})
    set_target_properties(${TARGET_NAME}
        PROPERTIES FOLDER "Auxiliary/ClangFormat"
        EXCLUDE_FROM_ALL True
        EXCLUDE_FROM_DEFAULT_BUILD True
        )
ENDMACRO()

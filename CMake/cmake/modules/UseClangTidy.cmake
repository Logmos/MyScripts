macro( CLANGTIDY )
    cmake_parse_arguments(CLANGTIDY "" "" "NAME;SWITCHES;SOURCES" ${ARGN} )

    if (CLANGTIDY_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "CLANGFORMATS Unknown argument: ${CLANGTIDY_UNPARSED_ARGUMENTS}")
    endif()

    find_program(CLANGTIDY_EXECUTABLE NAMES clang-tidy PATHS
        "${CLANGTIDY_PATH}")
    if(NOT CLANGTIDY_EXECUTABLE)
        message(FATAL_ERROR "clang-tidy not found!")
    endif()

    set(TARGET_NAME clang-tidy_${CLANGTIDY_NAME})
    add_custom_target(${TARGET_NAME}
        COMMAND clang-tidy
        ${CLANGTIDY_SWITCHES}
        ${CLANGTIDY_SOURCES}
        WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT
        "Running ${TARGET_NAME} for ${CLANGTIDY_SOURCES}"
        )
    add_dependencies(clangTidy ${TARGET_NAME})
    set_target_properties(${TARGET_NAME}
        PROPERTIES FOLDER "Auxiliary/ClangTidy"
        EXCLUDE_FROM_ALL True
        EXCLUDE_FROM_DEFAULT_BUILD True
        )
ENDMACRO()

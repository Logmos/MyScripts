macro( CHECKAPI )
    cmake_parse_arguments(CHECKAPI "" "" "NAME;SWITCHES;SOURCES" ${ARGN} )

    if (CHECKAPI_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "CHECKAPIS Unknown argument: ${CHECKAPI_UNPARSED_ARGUMENTS}")
    endif()

    if( CHECKAPI_DEBUG )
        set (CHECKAPI_SWITCHES ${CHECKAPI_SWITCHES --debug)
    endif()

    set(TARGET_NAME checkAPI_${CHECKAPI_NAME})
    add_custom_target(${TARGET_NAME}
        COMMAND ${PERL_EXECUTABLE}
        ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl
        ${CHECKAPI_SWITCHES}
        ${CHECKAPI_SOURCES}
        WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT
        "Running ${TARGET_NAME} for ${CHECKAPI_SOURCES}"
        )
    add_dependencies(checkAPI ${TARGET_NAME})
    set_target_properties(${TARGET_NAME}
        PROPERTIES FOLDER "Auxiliary/CheckAPIs"
        EXCLUDE_FROM_ALL True
        EXCLUDE_FROM_DEFAULT_BUILD True
        )
ENDMACRO()

function (CHECK_RUN program var ext)
set (${var}_FILE_NAME ${var}_test.${ext})
file (WRITE "${PROJECT_BINARY_DIR}/${${var}_FILE_NAME}" 
"${program}"
)
try_run (${var}_RUN ${var}_COMPILE "${PROJECT_BINARY_DIR}" "${PROJECT_BINARY_DIR}/${${var}_FILE_NAME}")
FILE (REMOVE "${PROJECT_BINARY_DIR}/${${var}_FILE_NAME}")
if (${var}_COMPILE)
	if (${var}_RUN EQUAL 0)
		set (${var} 1 PARENT_SCOPE)
	endif ()
endif ()
endfunction ()
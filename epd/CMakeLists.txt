set (SOURCE
	${SOURCE}
	${CMAKE_CURRENT_SOURCE_DIR}/epd.c
	PARENT_SCOPE)
	
set (HEADERS
	${HEADERS}
	${CMAKE_CURRENT_SOURCE_DIR}/epdInt.h
	${CMAKE_CURRENT_SOURCE_DIR}/epd.h
	PARENT_SCOPE)
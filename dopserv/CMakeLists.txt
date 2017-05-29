SET(GCC_OPTIMIZATION_COMPILE_FLAGS)
SET( CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${GCC_OPTIMIZATION_COMPILE_FLAGS} -DBARE" )

set(SOURCES dopserv.c dopserv_noio.c bare/libc.c)
add_application(dopserv "${SOURCES}")

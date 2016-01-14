# Copyright (C) 2015-2016 NXP B.V. All rights reserved.

if(TARGET_NXPDK5_JN517X_GCC_TOOLCHAIN_INCLUDED)
    return()
endif()
set(TARGET_NXPDK5_JN517X_GCC_TOOLCHAIN_INCLUDED 1)

# provide compatibility definitions for compiling with this target: these are
# definitions that legacy code assumes will be defined. Before adding something
# here, think VERY CAREFULLY if you can't change anywhere that relies on the
# definition that you're about to add to rely on the TARGET_LIKE_XXX
# definitions that yotta provides based on the target.json file.
#
add_definitions("-DJENNIC_CHIP_JN5179 -DJENNIC_CHIP_FAMILY_JN517x -DCHIP_JN517x -DCPU_JN517x -DTARGET_JN517x -D__CODE_RED -D__NEWLIB__ -D__USE_CMSIS -DTARGET_JN517X")
add_definitions(-DJN517x=5170 -DJN5179=5179 -DJENNIC_CHIP_NAME=_JN5179 -DJENNIC_CHIP_FAMILY_NAME=_JN517x -DJENNIC_HW_BBC_DMA=1 -DJENNIC_HW_BBC_ISA=1)

# append non-generic flags, and set JN517x-specific link script

set(_CPU_COMPILATION_OPTIONS "-mcpu=cortex-m3 -msoft-float -mthumb -D__thumb2__")

set(CMAKE_C_FLAGS_INIT             "${CMAKE_C_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_ASM_FLAGS_INIT           "${CMAKE_ASM_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_CXX_FLAGS_INIT           "${CMAKE_CXX_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${CMAKE_MODULE_LINKER_FLAGS_INIT} -mcpu=cortex-m3 -msoft-float -mthumb -u _printf_float")

if(CMAKE_BUILD_TYPE MATCHES Debug)
	set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} -mcpu=cortex-m3 -msoft-float -mthumb -u _printf_float -Wl,--defsym,__sw_configuration=0x0103 -L\"${CMAKE_CURRENT_LIST_DIR}/../ld\" -T\"${CMAKE_CURRENT_LIST_DIR}/../ld/JN5179.ld\"")
else()
	set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} -mcpu=cortex-m3 -msoft-float -mthumb -u _printf_float -L\"${CMAKE_CURRENT_LIST_DIR}/../ld\" -T\"${CMAKE_CURRENT_LIST_DIR}/../ld/JN5179.ld\"")
endif()	

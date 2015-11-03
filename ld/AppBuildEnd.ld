/****************************************************************************
 *
 * This software is owned by NXP B.V. and/or its supplier and is protected
 * under applicable copyright laws. All rights are reserved. We grant You,
 * and any third parties, a license to use this software solely and
 * exclusively on NXP products [NXP Microcontrollers such as JN5148, JN5142, JN5139].
 * You, and any third parties must reproduce the copyright and warranty notice
 * and any other legend of ownership on each copy or partial copy of the
 * software.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright NXP B.V. 2014. All rights reserved
 *
 ***************************************************************************/

/* EXTERN(u32HeapStart); */

SECTIONS
{
    .init ALIGN(4) :
    {
        KEEP (*(.init))
    } >flash =0xFF

    .fini ALIGN(4) :
    {
        KEEP (*(.fini))
    } >flash =0xFF

    .rodata ALIGN(4) :
    {
        *(.rodata)
        *(.rodata*)
    } >flash =0xFF

    .readonly ALIGN(4) :
    {
        KEEP (*(.readonly*))
    } >flash =0xFF
	
	/*
     * for exception handling/unwind - some Newlib functions (in common
     * with C++ and STDC++) use this.
     */
	.text ALIGN(4) :
    {
        __stext = .;
        *(.text*)
		*(.glue_7*)
        *(.vfp11_veneer)
        *(.v4_bx)
        *(.iplt)
        *(.rel.*)
			
		/* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)
        . = ALIGN(4);
	} >flash = 0xFF
	
	.ARM.extab ALIGN(4) :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > flash
    
	.ARM.exidx ALIGN(4) :
    {
		__exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
		__exidx_end = .;
		__flash_end = ABSOLUTE(.);
    } > flash
	
	__etext = .;
	
	/* Variables that needs to be at fixed location in flash */
    .constant_vars ABSOLUTE(__constant_vars) :
    {
        KEEP (*(.constant_vars))
        . = ALIGN(4);
    } >flash =0xFF

/****************************************************************************/
/***        RAM layout                                                    ***/
/****************************************************************************/

    . = ORIGIN(ram);

    __ram_start = ABSOLUTE(.);
    __internal_ram_start = ABSOLUTE(__ram_start) - 0x90;
    __ram_end = ORIGIN(ram) + LENGTH(ram);

    /*.data ALIGN(4) : AT ((LOADADDR(.text) + SIZEOF(.text) + SIZEOF(.ARM.exidx) + 3) & ~ 3)*/
	.data ALIGN(4) : AT (__etext)
	{
        __ram_data_start = ABSOLUTE(.);

		*(.data)
        *(.data*)
		*(vtable)
        *(.ram_code*)
		*(.igot.plt)
		
		. = ALIGN(4);
		/* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        __ram_data_end = ABSOLUTE(.);
        __ram_data_length = (__ram_data_end - __ram_data_start + 3) & ~ 3;
    } >ram

    .bss ALIGN(4) :
    {
        *(.bss.dontinitinboot)
        __bss_start = ABSOLUTE(.);
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = ABSOLUTE(.);
        __bss_length = (__bss_end - __bss_start + 3) & ~ 3;
    } >ram
    
    .heap ALIGN (0x4) :
    {
        __heap_start = ABSOLUTE(.);
		__end__ = .;
		end = __end__;
		*(.heap*);
        . += __minimum_heap_size;
		__HeapLimit = .;
    } >ram

    .stack ABSOLUTE(ORIGIN(ram) + LENGTH(ram) - __stack_size) :
    {
        /* make end of heap the bottom of the stack */
        __heap_end = ABSOLUTE(.);
        __stack_low_water_mark = ABSOLUTE(.);
        . += __stack_size;
        __stack_top = ABSOLUTE(.);
    } >ram
    
    /* Test to check if the .data initialisation values in flash has gone
       past the end of the available space; the linker doesn't throw an
       error if that has happened. The following forces a byte to be
       stored after the .data initialisation values, but it is marked as
       NOLOAD so it never gets into the binary */
    .test (((LOADADDR(.text) + SIZEOF(.text) + 3) & ~ 3) + SIZEOF(.data)) (NOLOAD):
    {
	BYTE(0xff)
    } > flash
}

_flash_data_start = LOADADDR(.data);
_ram_data_start = __ram_data_start;
_ram_data_length = (__ram_data_end - __ram_data_start + 3) & ~ 3;
_bss_start = __bss_start;
_bss_length = (__bss_end - __bss_start + 3) & ~ 3;
_image_length = (__flash_end - __flash_start + _ram_data_length + 3) & ~ 3;

_heap_start   = __heap_start;
_heap_end     = __heap_end;
_ram_top      = ABSOLUTE(ORIGIN(ram)) + LENGTH(ram);
ram_top      = ABSOLUTE(ORIGIN(ram)) + LENGTH(ram);

/*_app_ram_start = 0x01001580; */ /* Page 5, word 8 (16-byte words, 16 words per page) */
/* PROVIDE(_heap_location  = u32HeapStart); */
PROVIDE(__heap_size = SIZEOF(.heap));
PROVIDE(__mbed_sbrk_start = ADDR(.heap));
PROVIDE(__mbed_krbs_start = ADDR(.heap) + SIZEOF(.heap));

ENTRY(main);

/****************************************************************************/
/***        End of file                                                   ***/
/****************************************************************************/

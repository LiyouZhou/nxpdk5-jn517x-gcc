/*###############################################################################
#
# MODULE:             AppBuildStart.ld
#
# COMPONENT:          
#
# AUTHOR:             
#
# DESCRIPTION:        Linker command file
#              
#
# $HeadURL:  $
#
# REVISION:           
#
# LAST MODIFIED BY:   
#
# $LastChangedDate: $
#
# $Id:  $
#
###############################################################################
#
# This software is owned by NXP B.V. and/or its supplier and is protected
# under applicable copyright laws. All rights are reserved. We grant You,
# and any third parties, a license to use this software solely and
# exclusively on NXP products [NXP Microcontrollers such as JN514x, JN516x, JN517x].
# You, and any third parties must reproduce the copyright and warranty notice 
# and any other legend of ownership on each  copy or partial copy of the software.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE. 
# 
# Copyright NXP B.V. 2015-2016. All rights reserved
#
###############################################################################*/

INCLUDE BootLoaderFunctions.ld
INCLUDE App_Stack_Size.ld
INCLUDE FixedLocationBootFunctions.ld

/* EXTERN(AppWarmStart)
EXTERN(AppColdStart) */

/* Set main to be equivalent to AppColdStart as this is the default
   breakpoint set by LPCxpresso */
/* main = AppColdStart; */

EXTERN(isr_handlers)
EXTERN(__wrap_main)
EXTERN(AppWarmStart)

/*EXTERN(vAHI_IntHandlerTimer2)
EXTERN(vAHI_IntHandlerTimer3)
EXTERN(vAHI_IntHandlerTimer4)
EXTERN(vAHI_IntHandlerTimer5)
EXTERN(vAHI_IntHandlerTimer6)
EXTERN(vAHI_IntHandlerTimer7)
EXTERN(vAHI_IntHandlerSysCtrl)
EXTERN(vACI_IntHandlerAes)
EXTERN(vAHI_IntHandlerUart0)
EXTERN(vAHI_IntHandlerUart1)
EXTERN(vAHI_IntHandlerSpiSlave)
EXTERN(vAHI_IntHandlerSpiMaster)
EXTERN(vAHI_I2CIntHandler)
EXTERN(vAHI_IntHandlerTimer0)
EXTERN(vAHI_IntHandlerTimer1)
EXTERN(vAHI_IntHandlerTimer8)
EXTERN(vAHI_IntHandlerAnalogPeriph)
EXTERN(vAHI_ExceptionHandlerWatchDog)*/

__minimum_heap_size = DEFINED(__minimum_heap_size) ? __minimum_heap_size : 8192;
__stack_size = DEFINED(__stack_size) ? __stack_size : 8192;
__magic_number_1 = DEFINED(__magic_number_1) ? __magic_number_1 : 0x12345678;
__magic_number_2 = DEFINED(__magic_number_2) ? __magic_number_2 : 0x22334455;
__magic_number_3 = DEFINED(__magic_number_3) ? __magic_number_3 : 0x66778899;
__configuration = DEFINED(__configuration) ? __configuration : 0x08;
__status = DEFINED(__status) ? __status : 0x01;
__app_id = DEFINED(__app_id) ? __app_id : 0x0000;
__encryption_iv1 = DEFINED(__encryption_iv1) ? __encryption_iv1 : 0x00000000;
__encryption_iv2 = DEFINED(__encryption_iv2) ? __encryption_iv2 : 0x00000000;
__encryption_iv3 = DEFINED(__encryption_iv3) ? __encryption_iv3 : 0x00000000;
__encryption_iv4 = DEFINED(__encryption_iv4) ? __encryption_iv4 : 0x0000;
__sw_configuration = DEFINED(__sw_configuration) ? __sw_configuration : 0x0103;
__image_start = DEFINED(__image_start) ? __image_start : 0x00080000;
__constant_vars = DEFINED(__constant_vars) ? __constant_vars : .;

MEMORY
{
    flash (rx)          : ORIGIN = 0x00080000, LENGTH = 512k
    ram (rwx)           : ORIGIN = 0x20000090, LENGTH = (32k - 0x90)
}

SECTIONS
{
/****************************************************************************/
/***        FLASH layout                                                  ***/
/****************************************************************************/

    .version ABSOLUTE(__image_start):
    {
        __flash_start = ABSOLUTE(.);

        /*
         * 000A - Chip Type 5179
         * 03   - 32K Ram
         * 0F   - 512K Flash
         */
        LONG(0x0F03000A)
    } >flash

    .bir :
    {
        /* Magic number */
        LONG(__magic_number_1)
        LONG(__magic_number_2)
        LONG(__magic_number_3)

        /* Configuration (32K, DRE, 16MHz) */
        BYTE(__configuration)

        /* Status */
        BYTE(__status)

        /* Application ID */
        SHORT(__app_id)
    } >flash

    .flashheader :
    {
        /* Encryption IV */
        LONG(__encryption_iv1)
        LONG(__encryption_iv2)
        LONG(__encryption_iv3)
        SHORT(__encryption_iv4)

        /* SW Config Word Format
         *
         * JTAG Pin Enables (1 Enable, 0 Disable)
         * ---------------------------------------
         * Bit  Description
         * ---------------------------------------
         *
         * 0    TCK Enable
         * 1    TMS Enable
         * 2    TDO Enable
         * 3    TDI Enable
         *
         * JTAG Pin Configuration Data
         * ---------------------------------------
         * Bit  Description
         * ---------------------------------------
         *
         * 4    0 - TCK on DIO17
         *      1 - TCK on DIO6
         * 5    0 - TMS on DIO11
         *      1 - TMS on DIO18
         * 6    0 - TDO on DIO9
         *      1 - TDO on DIO15
         * 7    0 - TDI on DIO10
         *      1 - TDI on DIO7
         *
         * 8    Debug Enable (1 Enable, 0 Disable)
         * ---------------------------------------
         */
        SHORT(__sw_configuration)

        _enc_start = ABSOLUTE(.);
        /* Text section length */
        LONG(ABSOLUTE(_image_length))

        /* Data section start address and length */
        LONG(ABSOLUTE(_flash_data_start))
        SHORT((ABSOLUTE(_ram_data_start) / 4) & 0xFFFF)
        SHORT((ABSOLUTE(_ram_data_length) / 4) & 0xFFFF)

        /* BSS section start address and length */
        SHORT((ABSOLUTE(_bss_start) / 4) & 0xFFFF)
        SHORT((ABSOLUTE(_bss_length) / 4) & 0xFFFF)

        /* Image entry points */
        LONG(ABSOLUTE(AppWarmStart))
        LONG(ABSOLUTE(__wrap_main))
    } >flash
        _enc_offset = (_enc_start & 0x0000000F);
 }
/****************************************************************************/
/***        End of file                                                   ***/
/****************************************************************************/

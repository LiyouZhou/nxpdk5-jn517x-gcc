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
 * Copyright NXP B.V. 2013. All rights reserved
 *
 ***************************************************************************/

/* Now building all code at once, so include vectors. MAC address is embedded
   in build for now */

SECTIONS
{
    /* We have 19 IRQs plus watchdog, so the vector table has (20 + 16) = 36
     * words. The vector table offset must be aligned to the number of 
     * exceptions in the vector table. The alignment has to be rounded up to
     * the next power of 2. Hence in this case we need to align to 64 word
     * boundary (or offset 0x100).
     */
    .vectors ALIGN(0x100) :
    {
        __vectors_length = 36 * 4;
        __vectors_start = ABSOLUTE(.);
        KEEP (*(.isr_handlers))
        /* . = __vectors_length; */
        __vectors_end = ABSOLUTE(.);
    } >flash =0xFF

    .exceptions ALIGN(4) :
    {
        KEEP (*(.exceptions*))
    } >flash =0xFF
}

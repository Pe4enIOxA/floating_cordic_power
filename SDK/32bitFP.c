/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "my_fp_32ip.h"
#include "xparameters.h"
#include "stdio.h"
#include "xil_io.h"

#include "xsdps.h"		/* SD device driver */
#include "ff.h"
#include "xil_cache.h"

#define SDCARD_CODE

#ifdef SDCARD_CODE

#define BUFFSIZE 1024
#define INOUTBUFFSIZE 50

/************************** Function Prototypes ******************************/
int SDCARD_Read_Write(void);
static int NumberReturn(int value);
static void Convert2HexaStr(UINT decimalNumber, char * hexadecimalNumber);
static u32 SixteenMul(u32 inputnum);

/************************** Variable Definitions *****************************/
static FIL fil;								/* File object */
static FIL ReadFilPtr;       	/* File object */
static FATFS fatfs;
static char FileName[32] = "Fout.txt";
static char *SD_File;
static int OutBufIndex = 11;
int     GlobalIndex = 0;
u32 baseaddr;

#ifdef __ICCARM__
#pragma data_alignment = 32
u8 DestinationAddress[BUFFSIZE];
u8 SourceAddress[BUFFSIZE];
#pragma data_alignment = 4
#else
u8 DestinationAddress[BUFFSIZE] __attribute__ ((aligned(32)));
u8 SourceAddress[BUFFSIZE] __attribute__ ((aligned(32)));
#endif

#endif //SDCARD_CODE


int main()
{
	int     Index;
	int Status;

    baseaddr = XPAR_MY_FP_32IP_0_S00_AXI_BASEADDR;
    xil_printf("Memory address is 0x%08x\n\r", baseaddr);

#ifdef SDCARD_CODE

	xil_printf("SD Polled File System Example Test \r\n");

	Status = SDCARD_Read_Write();

	if (Status != XST_SUCCESS) {
		xil_printf("SD Polled File System Example Test failed \r\n");
		return XST_FAILURE;
	}

	xil_printf("Successfully ran SD Polled File System Example Test \r\n");

	//disable_caches();

	return XST_SUCCESS;

#endif // SDCARD_CODE

    return 0;
}

#ifdef SDCARD_CODE

/*****************************************************************************/
/**
*
* File system example using SD driver to write to and read from an SD card
* in polled mode. This example creates a new file on an
* SD card (which is previously formatted with FATFS), write data to the file
* and reads the same data back to verify.
*
* @param	None
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None
*
******************************************************************************/
int SDCARD_Read_Write(void)
{
	FRESULT Res,fr;
	UINT NumBytesWritten;
	u32 BuffCnt=0;
	u32 FileSize = BUFFSIZE;
	TCHAR *Path = "0:/";
	char StoreData[OutBufIndex];
	char LineBuff[32] = {0}; 		/* Line buffer */
	char ReadBuff[32] = {0};				/* Get only 8 bits of each line into this Buffer */
	TCHAR *LineTemp = (TCHAR *) NULL;	/* Temp pointer to store return address from f_gets() */
	int LoopCntNib=0, LoopCountNum = 0;	/* Varibales for loop counters */
	int TempResult=0;					/* Temp variable */
	int DecimalResult = 0;
	int OutBufIndex = 0;
	int dummyvar1, dummyvar2=0, SampCounter=0;
	int ResArrayBufCounter = 0;
	int ArrayBufCounter = 0;
	int LinesCountVar=0;
	int WordsCountVar=0;
	u32 Sixresult = 1;

	UINT ArrayBuffer[INOUTBUFFSIZE*2] = {0};
	UINT ResArrayBuffer[INOUTBUFFSIZE] = {0};


	/*
	 * Register volume work area, initialize device
	 */
	Res = f_mount(&fatfs, Path, 0);

	if (Res != FR_OK) {
		return XST_FAILURE;
	}

	// Initialize output buff to zeros
	for(dummyvar2 = 0; dummyvar2 < OutBufIndex; dummyvar2++){
		StoreData[dummyvar2] = 48;
	}

	/* Open input text file in Read Mode*/
	fr = f_open(&ReadFilPtr, "Tester.txt", FA_READ);
	if (fr) return (int)fr;				// Exit if something wrong

	/*
		 * Open file with required permissions.
		 * Here - Creating new file with read/write permissions. .
		 */
		SD_File = (char *)FileName;

		Res = f_open(&fil, SD_File, FA_CREATE_ALWAYS | FA_WRITE | FA_READ);
		if (Res) {
			return XST_FAILURE;
		}

		/*
		 * Pointer to beginning of file .
		 */
		Res = f_lseek(&fil, 0);
		if (Res) {
			return XST_FAILURE;
		}

	while(1)
	    {
	    	if(f_eof(&ReadFilPtr)== 1)		// Check whether End of file is reached
	    		break;						// if so, then break the loop, stop reading lines
	    	else
	    	{
	    		/* Since we want 8 bits of each line,
	    		 * then three characters for \r, \n, \0 we read 11 characters of each line */
	    		LineTemp = (TCHAR*) f_gets(LineBuff, 35, &ReadFilPtr);
	    		LinesCountVar++;
	    		if(LineTemp == NULL)
	    			return 1;

	    		/* copy only first 8 characters of each line i.e. an 8 bit binary number */
	    		for(LoopCntNib = 0; LoopCntNib < 32; LoopCntNib++)
	    		{
	    			ReadBuff[LoopCntNib] = LineBuff[LoopCntNib];
	    		}
	    		LoopCntNib = 0;

				/* This for loop will take each nibble and converts string to number.
				 * hence looped twice to cover 8 bits
				 */
	    		for(LoopCountNum = 0; LoopCountNum < 8; LoopCountNum++)
				{
	    			/* Take 4 bits and convert string to number ( atoi() kind of)
	    			 * Store it in temporary res */
					for ( ; LoopCntNib < (4 +(LoopCountNum*4) ); LoopCntNib++)
						TempResult = TempResult*10 + ReadBuff[LoopCntNib] - '0';

					/* Call the static function that maps Binary look alike
					 * number to its equivalent Hexa decimal value */
					dummyvar1 = NumberReturn(TempResult);

					// Convert a nibble to hexal and shift to MSB for every LoopCountNum
					// iteration. hence used static function SixteenMul()
					if(LoopCountNum <= 6)
					{
						Sixresult = SixteenMul(8- (LoopCountNum+1));
						DecimalResult =  DecimalResult + dummyvar1 * Sixresult;
					}
					else if (LoopCountNum == 7)
						DecimalResult =  DecimalResult + dummyvar1;
					else
						DecimalResult = DecimalResult;

					dummyvar1 = 0;		// clear the TempResult before taking next Nibble
					TempResult = 0;

				}

				ArrayBuffer[ArrayBufCounter++] =  DecimalResult;//EightDigitNum;
				WordsCountVar++;
				GlobalIndex++;
				DecimalResult = 0;
	    		LoopCountNum = 0;
  	    		LoopCntNib = 0;

	    	} // end of else => one input read ( one 4 byte binary data i.e. one line is done) and stored into Buffer


	    	/* Writing to IP Memory and read the result */
	    	if(LinesCountVar%2 == 0) // Two lines completed, then process data
	    	{
	    		for(SampCounter = ArrayBufCounter-2; SampCounter < ArrayBufCounter; SampCounter++ )
				{
					xil_printf("%d\n\r", ArrayBuffer[SampCounter]);
					MY_FP_32IP_mWriteMemory(baseaddr, ArrayBuffer[SampCounter]);
				}

	    		for(SampCounter = 0; SampCounter < 1; SampCounter++ )
				{
	    			ResArrayBuffer[ResArrayBufCounter] = MY_FP_32IP_mReadMemory(baseaddr);
					xil_printf("%d\n\r", ResArrayBuffer[ResArrayBufCounter++]);
				}

				SampCounter = 0;

	    	} // End of if

	    } //end of while( 1) loop => All inputs read and stored into buffer

		/* Prepare the final buffer which can be used to store into a file */
		for(SampCounter = 0; SampCounter < (LinesCountVar/2); SampCounter++ )
		{
			StoreData[0] = 48;
			StoreData[1] = 'x';
			StoreData[10] = 10;

			// Store the Final value of 8 bytes into Temp buffer
			Convert2HexaStr(ResArrayBuffer[SampCounter], StoreData);

			// Store 11 bytes of data into final buffer. Keep accumulating all the data
			for(dummyvar2 =0; dummyvar2 < 11; dummyvar2++){
								SourceAddress[BuffCnt++] = StoreData[dummyvar2];
			}
		}

		// Put space character at the end of Buffer
		for(; BuffCnt < BUFFSIZE; ){
							SourceAddress[BuffCnt++] = 9;
		}

		xil_printf("Number of Input Data Read : %d\n\r", LinesCountVar);
		xil_printf("Number of Output Data written : %d\n\r", WordsCountVar);

		/*
		 * Write data to file.
		 */
		Res = f_write(&fil, (const void*)SourceAddress, FileSize,
				&NumBytesWritten);

		if (Res) {
			return XST_FAILURE;
		}

	/*
	 * Close file.
	 */
	Res = f_close(&ReadFilPtr);
	if (Res) {
		return XST_FAILURE;
	}

	Res = f_close(&fil);
	if (Res) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/* This function take the inputnum and just return 16 power of inputnum
 * example: inputnum = 3, this function returns , 16^3 = 16*16*16 = 4096
 */
static u32 SixteenMul(u32 inputnum)
{
	int i, result=1;

	for(i=0;i<inputnum;i++)
	{
		result = result * 16;
	}
	return result;
}
static void Convert2HexaStr(UINT decimalNumber, char * hexadecimalNumber)
{

 UINT quotient;
 int i = 9, temp;

	quotient = decimalNumber;

	while (quotient != 0){
		temp = quotient % 16;

		//To convert integer into character
		if (temp < 10)
			temp = temp + 48;
		else
			temp = temp + 55;

		hexadecimalNumber[i--] = temp;
		quotient = quotient / 16;
	}

}

/* This file takes a value look alike binary numbers and returns its equivalent
 * Hexa decimal value
 * Example: if we send 1010, it returns 0xA, for 1001 it returns 0x9
 * but the number we are sending is an integer not binary :)
 */
static int NumberReturn(int value)
{
	int FinalRes;

	switch(value){
		    		case 0: //0
		    			FinalRes = 0;
		    			break;
		    		case 1:
		    			FinalRes = 1; //1
		    			break;
		    		case 10: //2
		    			FinalRes = 2;
		    			break;
		    		case 11:
		    			FinalRes = 3;
		    			break;
		    		case 100:
		    			FinalRes = 4;
		    			break;
		    		case 101:
		    			FinalRes = 5;
		    			break;
		    		case 110:
		    			FinalRes = 6;
		    			break;
		    		case 111:
		    			FinalRes = 7;
		    			break;
		    		case 1000:
		    			FinalRes = 8;
		    			break;
		    		case 1001:
		    			FinalRes = 9;
		    			break;
		    		case 1010:
		    			FinalRes = 0xA;
		    			break;
		    		case 1011:
		    			FinalRes = 0xB;
		    			break;
		    		case 1100:
		    			FinalRes = 0xC;
		    			break;
		    		case 1101:
		    			FinalRes = 0xD;
		    			break;
		    		case 1110:
		    			FinalRes = 0xE;
		    			break;
		    		case 1111:
		    			FinalRes = 0xF;
		    			break;
		    		default:
		    			FinalRes = 0xFE; // Some junk value to check for an error

		    		}

	return FinalRes;
}

#endif //SDCARD_CODE

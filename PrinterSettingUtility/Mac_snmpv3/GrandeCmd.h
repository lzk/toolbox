/*********************************************************************
*	File:		GrandeCmd.h
*	
*	Description:	Define Grande Command Structure.
*
*	Author:	Devid
*
*	Copyright: 	© Copyright 2009 Liteon, Inc. All rights reserved.
*
**********************************************************************/

#ifndef __GRANDECMD_H__
#define __GRANDECMD_H__
#pragma once

#include <stdlib.h> // pulls in declaration of malloc, free
#include <string.h> // pulls in declaration for strlen.
#include <stdio.h>

#if __LP64__
typedef unsigned int       UInt32;
#else
typedef unsigned long      UInt32;
#endif

#ifndef DWORD
typedef UInt32 DWORD;
#endif  // DWORD

#ifndef BOOL
#define BOOL int
#endif
typedef unsigned char       BYTE;
typedef unsigned short      WORD;


#pragma	pack(1) 
typedef struct {
	BYTE	cmd_mark;		// 0x1b
//	BYTE	utility;			// ¡¥M¡¦ (0x4D): Stands for Machine Setup Utility
	BYTE	utility_mark1;	// ¡¥M¡¦ (0x4D): Stands for Machine Setup Utility
	BYTE	utility_mark2;	// ¡¥S¡¦ (0x53): Stands for Machine Setup Utility
	BYTE	utility_mark3;	// ¡¥U¡¦ (0x55): Stands for Machine Setup Utility

	BYTE	cmd_group;		// Refer to the table below (Command Group).
	BYTE	cmd_code;		// Refer to the table below (Command Code).
	//BYTE	Need_Restart;      // 0x00: not restart; Nonzero: Need restart
	//BYTE	Reserved;         // Only one byte is required because FW code eliminate 							the first Two bytes of this structure.
	DWORD	size;          	// the size of payload. Zero is allowed.
} GRANDE_COMMAND_HEADER;
#pragma	pack()

#pragma pack(1)
typedef struct {
	BYTE	rsp_mark;		// 0x1c
	BYTE	errors;			// 0x00: Success; Nonzero: errors (code TBD).
	BYTE	cmd_group;		// Refer to the table below.
	BYTE	cmd_code;		// Refer to the table below.
	BYTE	has_next_rsp;     // If there is one or more response after this, the 							flag should be set to 0x01. If current response 							is the final one, set it to 0.
	BYTE	Reaseved[3];      // Three bytes are required to let ¡§size¡¨ aligned to 						a 4-byte address
	DWORD	size;          	// the size of payload. Zero is allowed.
} GRANDE_RESPONSE_HEADER;
#pragma pack()

#pragma	pack(1) 
typedef struct DEV_PSR_PRINTERINFORMATION
{
	GRANDE_RESPONSE_HEADER rsp_header;
	char cDellServiceTagNumber[32];
	char cPrinterSerialNumber[32];
	char cPrinterType[32];
	char cAssetTagNumber[32];
	char cMemoryCapacity[32];
	char cProcessorSpeed[32];
	char cFirmwareVersion[32];
	char cNetworkFirmwareVersion[32];
	char cMCUFirmwareVersion[32];
	char cPrintingSpeedColor[32];
	char cPrintingSpeedMonochrome[32];
	char reserve[1024];
}DEV_PSR_PRINTERINFORMATION, *pDEV_PSR_PRINTERINFORMATION;
#pragma	pack()

#pragma	pack(1) 
typedef struct DEV_PL_PRINTER_NAME
{
	GRANDE_RESPONSE_HEADER rsp_header;
	char cPrinterName[32]; // NULL terminated string
	char reserve[1024];
} DEV_PL_PRINTER_NAME, *pDEV_PL_PRINTER_NAME;
#pragma	pack()

#pragma	pack(1) 
typedef struct {
	////////////////////////////////////////////////////
	// Consumable 
	////////////////////////////////////////////////////
	BYTE	TonelStatusLevelK; 	
	BYTE	TonelStatusLevelC; 	
	BYTE	TonelStatusLevelM; 	
	BYTE	TonelStatusLevelY; 	
	BYTE	DrumStatusLifeRemain;

	////////////////////////////////////////////////////
	// Covers 
	////////////////////////////////////////////////////
	BYTE	CoverStatusFlags; 

	////////////////////////////////////////////////////
	// Paper Tray
	////////////////////////////////////////////////////
	BYTE	PaperTrayStatus; 	
	BYTE	PaperSize;	

	////////////////////////////////////////////////////
	// Output Tray
	////////////////////////////////////////////////////
	BYTE	OutputTrayLevel; 

	////////////////////////////////////////////////////
	// General Status and information
	////////////////////////////////////////////////////
	BYTE	PrinterStatus;
	WORD	OwnerName[16];
	WORD	DocuName[16];
	BYTE	ErrorCodeGroup;
	BYTE	ErrorCodeID;
	WORD	PrintingPage;	
	WORD	Copies;
	DWORD	TotalCounter;	
	////////////////////////////////////////////////////
	// TRC index (For ULC only)
	////////////////////////////////////////////////////
	BYTE	TRCCurve[12];	
	BYTE	TonerSize[4];
	BYTE	PaperType;
	BYTE	NonDellTonerMode;
	BYTE	AioStatus;
	BYTE	bReserved;
	WORD	wReserved1;
	WORD	wReserved2;
} PRINTER_STATUS;
#pragma	pack()


extern "C" {
	int DecodStatusFromDeviceID(char* device_id, PRINTER_STATUS* status);
}

class CGrandeCmd
{
public:
	CGrandeCmd();
	~CGrandeCmd();


	int GetPrinterStatus(PRINTER_STATUS& status);
	int DecodStatusFromDeviceID(char* device_id, PRINTER_STATUS* status);
};


#endif //__GRANDECMD_H__


//
//  CustomTextFieldFormatter.h
//  OutputBins2PDE
//
//  Created by user on 11/22/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface CustomTextFieldFormatter : NSNumberFormatter {
	int maxLength,maxNumber,minLength;
	BOOL bNumOnly;
	BOOL bPhNum;
	BOOL ipA; //filter 127
	int funcMode;  //0:none 1:name 2:phone number
	NSButton *TextBtnCtrl;
	BOOL bAlphaOnly;
	NSString *outString;
}
- (void)setMaximumLength:(int)len;
- (void)setMinimumLength:(int)len;
- (int)maximumLength;
- (void)setNumberOnly:(BOOL)bNO;
- (void)setMaximumNumber:(int)number;

- (void)setPhoneNumber:(BOOL)bPN;
- (void)setNameAlpha:(BOOL)bAlpha;

- (void)setIPA:(BOOL)bIPA;
- (void)setTF:(int)fmode  textfiled:(NSButton*)TF;
- (BOOL)bNumberOnly;
-(BOOL) IsAlphanumericAndSymbolsl:(NSString*) text;
@end

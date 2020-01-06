//
//  CustomTextFieldFormatter.m
//  OutputBins2PDE
//
//  Created by user on 11/22/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomTextFieldFormatter.h"



@implementation CustomTextFieldFormatter

- (id)init {
	self=[super init];
	if (self != nil)
	{
		maxNumber = 255; //ipv4
		maxLength = INT_MAX;
		minLength = 0;
		bNumOnly = FALSE;
		bPhNum = FALSE;
		ipA = FALSE;
		bAlphaOnly = FALSE;
		funcMode = 0;
		[TextBtnCtrl setEnabled:FALSE];
	}
	return self;
}

- (void)setMinimumLength:(int)len {
	minLength = len;
}

- (void)setMaximumLength:(int)len {
	maxLength = len;
}

- (void)setMaximumNumber:(int)number {
	maxNumber = number;
}

- (void)setNumberOnly:(BOOL)bNO {
	bNumOnly = bNO;
}

- (void)setIPA:(BOOL)bIPA {
	ipA = bIPA;
}

- (void)setNameAlpha:(BOOL)bAlpha {
	bAlphaOnly = bAlpha;
}


- (void)setPhoneNumber:(BOOL)bPN {
	bPhNum = bPN;
}

- (void)setTF:(int)fmode  textfiled:(NSButton*)TF{
	funcMode = fmode; 
	if(TF!=nil)
		TextBtnCtrl = TF;
	
	
	
}

- (int)maximumLength {
	return maxLength;
}

- (BOOL)bNumberOnly {
	return bNumOnly;
}
- (BOOL)bPhoneNumber {
	return bPhNum;
}


- (NSString *)stringForObjectValue:(id)object {
    
    //int size = [object length];


    return (NSString*)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error {
	*object = string;
	NSCharacterSet *nonDigits,*PhoneChar;

    if(bAlphaOnly) {
        
        if ( ![self IsAlphanumericAndSymbolsl:string])
		{
            return NO;
            
        }
    }
       
    else if (bPhNum) {
            PhoneChar = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789*#:"] invertedSet];
            if ([string rangeOfCharacterFromSet: PhoneChar options: NSLiteralSearch].location != NSNotFound) {
                return NO;
            }

        
    }
    else if (bNumOnly) {
        PhoneChar = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([string rangeOfCharacterFromSet: PhoneChar options: NSLiteralSearch].location != NSNotFound) {
            return NO;
        }
        
        
    }
        
    
    return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error
{
	NSCharacterSet *nonDigits,*PhoneChar;
    NSRange newStuff;
    NSString *newStuffString;
	
	
			
	
    NSUInteger size = [*partialStringPtr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
#if 0
	if (TextBtnCtrl != nil) {
		
		switch (funcMode) {
			case 1://name
				if (size>0) {
					[TextBtnCtrl setEnabled:TRUE]; 
				}
				else {
					[TextBtnCtrl setEnabled:FALSE]; 
				}
				
				break;
			case 2://phone number
				if (size>0) {
					[TextBtnCtrl setEnabled:TRUE]; 
				}
				else {
					[TextBtnCtrl setEnabled:FALSE]; 
				}
			default:
				break;
		}
	}
#endif
	
	if(bNumOnly)
	{
		nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
		newStuff = NSMakeRange(origSelRange.location,
							   proposedSelRangePtr->location
							   - origSelRange.location);
		newStuffString = [*partialStringPtr substringWithRange: newStuff];
		
		
		if ( size > maxLength || size < minLength || [newStuffString rangeOfCharacterFromSet: nonDigits options: NSLiteralSearch].location != NSNotFound || [*partialStringPtr intValue] > maxNumber ||[*partialStringPtr intValue] < 0)
		{
			
			return NO;
		}

		
		if(ipA)
		{
			if ( size > maxLength || size < minLength || [newStuffString rangeOfCharacterFromSet: nonDigits options: NSLiteralSearch].location != NSNotFound || [*partialStringPtr intValue] > maxNumber || [*partialStringPtr intValue] == 127 ||[*partialStringPtr intValue] < 0)
			{
				
				return NO;
			}
		}
		return YES;
	}
	else if(bPhNum)
	{
		PhoneChar = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789*#:-"] invertedSet];
		newStuff = NSMakeRange(origSelRange.location,
							   proposedSelRangePtr->location
							   - origSelRange.location);
		newStuffString = [*partialStringPtr substringWithRange: newStuff];
		
		
		if ( size > maxLength || size < minLength || [newStuffString rangeOfCharacterFromSet: PhoneChar options: NSLiteralSearch].location != NSNotFound)
		{
			return NO;
		}
		
		if (size>0) {
			[TextBtnCtrl setEnabled:TRUE]; 
		}
		else {
			[TextBtnCtrl setEnabled:FALSE]; 
		}
		return YES;
	}
	else if(bAlphaOnly) {
		

		if ( size > maxLength || size < minLength || ![self IsAlphanumericAndSymbolsl:*partialStringPtr])
		{
            

            
           // NSLog(@"new Range is: %@", NSStringFromRange(*proposedSelRangePtr));
           // newStuffString = [*partialStringPtr substringWithRange: newStuff];
            
           // NSLog(@"partialStringPtr=%@ newStuffString=%@",*partialStringPtr,newStuffString);
            
            
           // outString=origString;
            
           // NSLog(@"outStringPtr=%@",outString);
            //*partialStringPtr=@"a";
			return NO;
		}
		return YES;
	}
	else
	{
		if ( size > maxLength)
		{
			return NO;
		}
		return YES;
		
		
		
	}
}

-(BOOL) IsAlphanumericAndSymbolsl:(NSString*) text
{
	if (text != nil && [text isEqual:@""] == NO)
	{
		int i;
		
		int nLength = [text length];
		for (i = 0; i < nLength; i++)
		{
			unichar value = [text characterAtIndex:i];			
			
			if ((SInt16)value >= 0x20 && (SInt16)value < 0x7f)
			{
				continue;
			}
			else
			{
				return NO;
			}
		}
	}
	
	return YES;
}




- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
	return nil;
}

@end

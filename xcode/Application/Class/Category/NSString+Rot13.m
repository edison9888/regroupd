//
//  NSString+Rot13.m
//  Regroupd
//
//  Created by Hugh Lang on 1/18/14.
//
//

#import "NSString+Rot13.h"

@implementation NSString (Obfuscation)

- (NSString *)rot13 {
	const char *_string = [self cStringUsingEncoding:NSASCIIStringEncoding];
	int stringLength = [self length];
	char newString[stringLength+1];
    
	int x;
	for( x=0; x<stringLength; x++ )
	{
		unsigned int aCharacter = _string[x];
        
		if( 0x40 < aCharacter && aCharacter < 0x5B ) // A - Z
			newString[x] = (((aCharacter - 0x41) + 0x0D) % 0x1A) + 0x41;
		else if( 0x60 < aCharacter && aCharacter < 0x7B ) // a-z
			newString[x] = (((aCharacter - 0x61) + 0x0D) % 0x1A) + 0x61;
		else  // Not an alpha character
			newString[x] = aCharacter;
	}
    
	newString[x] = '\0';
    
	NSString *rotString = [NSString stringWithCString:newString encoding:NSASCIIStringEncoding];
	return( rotString );
}

@end
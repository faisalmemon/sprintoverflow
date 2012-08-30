//
//  soSecurity.m
//  SprintOverflow
//
//  Created by Faisal Memon on 29/08/2012.
//
//

#import "soSecurity.h"

@implementation soSecurity

+ (NSString*)createSecurityCode
{
    NSString *easyTranscribe = @"abcdefghkmnpqrtuvwxy2346789"; // similar looking characters removed  // Not NSLocalizedString
    int lengthEasyTranscribe = [easyTranscribe length];
    NSMutableString *randomString = [NSMutableString stringWithCapacity: SO_LENGTH_SECURITY_STRING];
    for (int i = 0; i < SO_LENGTH_SECURITY_STRING; i++) {
        [randomString appendFormat:@"%C", [easyTranscribe characterAtIndex:arc4random() % lengthEasyTranscribe]]; // Not NSLocalizedString
    }    
    return randomString;
}

@end

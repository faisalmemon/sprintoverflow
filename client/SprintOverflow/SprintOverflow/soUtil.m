//
//  soUtil.m
//  SprintOverflow
//
//  Created by Faisal Memon on 03/09/2012.
//
//

#import "soUtil.h"

@implementation soUtil

+ (BOOL)isValidEmail:(NSString *)checkString Strictly:(BOOL)strictFiltering
{
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; // Not NSLocalizedString
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*"; // Not NSLocalizedString
    NSString *emailRegex = strictFiltering ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; // Not NSLocalizedString
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString*)safeWebStringFromString:(NSString*)unsafeString
{
    CFStringRef preprocessedString
    = CFURLCreateStringByReplacingPercentEscapesUsingEncoding
    (
     kCFAllocatorDefault,
     (__bridge CFStringRef)(unsafeString),
     CFSTR(""),
     kCFStringEncodingUTF8);
    
    NSString * encodedString
    = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes
    (
     NULL,
     preprocessedString,
     NULL,
     (CFStringRef)@"!*'();:@&=+$,/?%#[]", // Not NSLocalizedString
     kCFStringEncodingUTF8);
    return encodedString;
}

//+    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[addedProjectJson UTF8String] length:[addedProjectJson length]] options:NSJSONReadingMutableContainers error:&error];

+ (NSDictionary*)DictionaryFromJson:(NSString*)json UpdateError:(NSError **)error_description
{
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[json UTF8String] length:[json length]] options:NSJSONReadingMutableContainers error:error_description];
}

+ (NSMutableArray*)ArrayFromJson:(NSString*)json UpdateError:(NSError **)error_description
{
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[json UTF8String] length:[json length]] options:NSJSONReadingMutableContainers error:error_description];
}

@end

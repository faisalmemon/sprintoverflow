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

enum treatment_t { soAccept, soReject, soEscapeQuote, soEscapeBackquote };

+ (enum treatment_t) jsonTreatmentForChar:(unichar)c
{
    if (c <= 0x1f && c >= 0 )
        return soReject;
    else if (c >= 0x7f && c <= 0x9f)
        return soReject;
    else if (c == '"')
        return soEscapeQuote;
    else if (c == '\\')
        return soEscapeBackquote;
    else return soAccept;
}

+ (NSString*)jsonSafeStringFromUserInput:(NSString*)userInput
{
    NSMutableString *safeString = [NSMutableString stringWithString:@""];
    int length = [userInput length];
    unichar c;
    for (int i = 0; i < length; i++) {
        c = [userInput characterAtIndex:i];
        switch ([self jsonTreatmentForChar:c])
        {
            case soAccept:
                [safeString appendFormat:@"%C", c];
                break;
            case soReject:
                break;
            case soEscapeBackquote:
                [safeString appendString:@"\\\\"];
                break;
            case soEscapeQuote:
                [safeString appendString:@"\\\""];
                break;
            default:
                break;
        }
    }
    return safeString;
}

+ (NSString*)userDisplayStringFromJsonSafeString:(NSString*)jsonSafeString
{
    NSMutableString *userDisplayString = [NSMutableString stringWithString:@""];
    int length = [jsonSafeString length];
    if (length <= 0)
        return nil;
    else if (length == 1)
        return jsonSafeString;
    
    unichar c1 = 0;
    for (int i = 0; i < length; i++) {
        c1 = [jsonSafeString characterAtIndex:i];
        if (i == length -1) {
            if (c1 == '\\') {
                // missing character after escape character; ignore
                return userDisplayString;
            } else {
                [userDisplayString appendFormat:@"%C", c1];
                return userDisplayString;
            }
        }
        switch (c1) {
            case '\\':
                [userDisplayString appendFormat:@"%C", [jsonSafeString characterAtIndex:i+1]];
                i++;
                break;

            default:
                [userDisplayString appendFormat:@"%C", c1];
                break;
        }
    }
    return userDisplayString;
}

+ (NSDictionary*)DictionaryFromJson:(NSString*)json UpdateError:(NSError **)error_description
{
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[json UTF8String] length:[json length]] options:NSJSONReadingMutableContainers error:error_description];
}

+ (NSMutableArray*)ArrayFromJson:(NSString*)json UpdateError:(NSError **)error_description
{
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[json UTF8String] length:[json length]] options:NSJSONReadingMutableContainers error:error_description];
}

+ (NSString*)getUtf8StringFromNsData:(NSData*)data UpdateError:(NSError **)error_description
{
    *error_description = nil;
    NSString* returnedString;
    /*
     We find that data, when wrapped as NSData, knows its data pointer and length.
     The data itself therefore is not NULL-terminated.  So when it is interpreted
     as string data (here UTF-8 encoded), a NULL-terminator needs to be added otherwise
     stray characters from the virtual memory page creep in, causing parsing errors.
     */
    if ([data length] <= 0) {
        return nil;
    }
    
    int lengthOfResponse = [data length];
    char *holdingAreaCString = malloc(lengthOfResponse + 1);
    if (holdingAreaCString != NULL) {
        @try {
            holdingAreaCString[lengthOfResponse] = '\0';
            [data getBytes:holdingAreaCString length:lengthOfResponse];
            returnedString = [[NSString alloc ] initWithCString:holdingAreaCString encoding:NSUTF8StringEncoding];
            return returnedString;
        } @finally {
            free(holdingAreaCString);
        }
    } else {
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject: NSLocalizedString(@"Could not allocate memory.  Shutdown other applications to free up some more memory.", @"Error seen when memory allocation failures occur") forKey:NSLocalizedDescriptionKey];
        *error_description = [NSError errorWithDomain:@"ApplicationDataConversion" code:SO_DATACONVERT_ERROR userInfo:userInfo]; // Not NSLocalizedString

        return nil;
    }    
}


@end

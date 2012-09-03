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

@end

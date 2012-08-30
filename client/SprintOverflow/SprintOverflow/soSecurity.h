//
//  soSecurity.h
//  SprintOverflow
//
//  Created by Faisal Memon on 29/08/2012.
//
//

#import <Foundation/Foundation.h>

#define SO_LENGTH_SECURITY_STRING  10
@interface soSecurity : NSObject {
    
}

+ (NSString*)createSecurityCode;

@end

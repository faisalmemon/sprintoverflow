//
//  soUtil.h
//  SprintOverflow
//
//  Created by Faisal Memon on 03/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface soUtil : NSObject

#define SO_DATACONVERT_ERROR 1

+ (BOOL)isValidEmail:(NSString *)checkString Strictly:(BOOL)strictFiltering;
+ (NSString*)safeWebStringFromString:(NSString*)unsafeString;
+ (NSDictionary*)DictionaryFromJson:(NSString*)json UpdateError:(NSError **)error_description;
+ (NSMutableArray*)ArrayFromJson:(NSString*)json UpdateError:(NSError **)error_description;
+ (NSString*)getUtf8StringFromNsData:(NSData*)data UpdateError:(NSError **)error_description;
+ (NSString*)userDisplayStringFromJsonSafeString:(NSString*)jsonSafeString;
+ (NSString*)jsonSafeStringFromUserInput:(NSString*)userInput;
@end

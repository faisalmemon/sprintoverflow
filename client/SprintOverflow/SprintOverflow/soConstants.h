//
//  soConstants.h
//  SprintOverflow
//
//  Created by Faisal Memon on 03/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface soConstants : NSObject

/*
 Resource names
 */
extern NSString *const ksoLockedImage;
extern NSString *const ksoUnlockedImage;

/*
 Convenience strings used to build up a JSON dictionary of key:values
 */
extern NSString *const ksoEmptyList;
extern NSString *const ksoOnePairJson;
extern NSString *const ksoTwoPairsJson;
extern NSString *const ksoThreePairsJson;
extern NSString *const ksoFourPairsJson;
extern NSString *const ksoTwoDictionaries;
extern NSString *const ksoThreeDictionaries;
extern NSString *const ksoDictTwoArray;
extern NSString *const ksoDictThreeArray;

/*
 Request Protocol
 */
extern NSString *const ksoClientVersion;
extern NSString *const ksoCreateProject;
extern NSString *const ksoDiscoverable;
extern NSString *const ksoEpic;
extern NSString *const ksoIdOrToken;
extern NSString *const ksoJoinProject;
extern NSString *const ksoLastFetch;
extern NSString *const ksoMode;
extern NSString *const ksoNextPush;
extern NSString *const ksoNO;
extern NSString *const ksoPending;
extern NSString *const ksoProjectId;
extern NSString *const ksoProjectOwnerEmail;
extern NSString *const ksoResolveList;
extern NSString *const ksoSecurityToken;
extern NSString *const ksoSoftDelete;
extern NSString *const ksoSprint;
extern NSString *const ksoStory;
extern NSString *const ksoTask;
extern NSString *const ksoToken;
extern NSString *const ksoYES;


extern NSString *const ksoVersion;


extern NSString *const ksoCreateNewProjectUrl;

/*
 Response Protocol
 */
extern NSString *const ksoServerNotRespondedYet;
extern NSString *const ksoServerDidNotRespond;


+ (UIColor *)faultyEmailAddressBackgroundColor;
@end

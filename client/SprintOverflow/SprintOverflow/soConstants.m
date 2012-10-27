//
//  soConstants.m
//  SprintOverflow
//
//  Created by Faisal Memon on 03/09/2012.
//
//  The file's constants assumed to never need localization and thus is
//  hardcoded as exempt from string checking in the script
//  findMissingLocalizedStrings.sh
//

#import "soConstants.h"

@implementation soConstants

/*
 Resources
 */
NSString *const ksoLockedImage = @"padlock-highres.png";
NSString *const ksoUnlockedImage = @"padlock-highres-unlocked.png";


NSString *const ksoEmptyList = @"[]";
NSString *const ksoOnePairJson = @"{\"%@\" : \"%@\"} ";
NSString *const ksoTwoPairsJson = @"{\"%@\" : \"%@\", \"%@\" : \"%@\"} ";
NSString *const ksoThreePairsJson = @"{\"%@\" : \"%@\", \"%@\" : \"%@\", \"%@\" : \"%@\"} ";
NSString *const ksoFourPairsJson = @"{\"%@\" : \"%@\", \"%@\" : \"%@\", \"%@\" : \"%@\", \"%@\" : \"%@\"} ";

NSString *const ksoTwoDictionaries = @"[ \"%@\" : %@, \"%@\" : %@ ]";
NSString *const ksoThreeDictionaries = @"[ \"%@\" : %@, \"%@\" : %@, \"%@\" : %@ ]";

NSString *const ksoDictTwoArray = @"{ \"%@\" : %@, \"%@\" : %@ }";
NSString *const ksoDictThreeArray = @"{ \"%@\" : %@, \"%@\" : %@, \"%@\" : %@ }";



/*
 These constants must match the symbolic names of the server-side enumerations in Request.java
 because that file, together with Response.java, is the official definition of the client-server
 protocol, and its documentation.
 
 These constants are kept in alphabetic order.
 */
NSString *const ksoClientVersion = @"ClientVersion";
NSString *const ksoCreateProject = @"CreateProject";
NSString *const ksoDiscoverable = @"Discoverable";
NSString *const ksoDidNotDiscover = @"DidNotDiscover";
NSString *const ksoEpic = @"Epic";
NSString *const ksoGenerationId = @"GenerationId";
NSString *const ksoIdOrToken = @"IdOrToken";
NSString *const ksoJoinProject = @"JoinProject";
NSString *const ksoLastFetch = @"LastFetch";
NSString *const ksoMode = @"Mode";
NSString *const ksoNextPush = @"NextPush";
NSString *const ksoNO = @"NO";
NSString *const ksoPending = @"Pending";
NSString *const ksoPendingQueue = @"PendingQueue";
NSString *const ksoProjectId = @"ProjectId";
NSString *const ksoProjectOwnerEmail = @"ProjectOwnerEmail";
NSString *const ksoResolveList = @"ResolveList";
NSString *const ksoSecurityToken = @"SecurityToken";
NSString *const ksoSoftDelete = @"SoftDelete";
NSString *const ksoSprint = @"Sprint";
NSString *const ksoStory = @"Story";
NSString *const ksoTask = @"Task";
NSString *const ksoToken = @"Token";
NSString *const ksoVersion = @"Version";
NSString *const ksoYES = @"YES";

/*
 These constants must match the symbolic names of the server-side enumerations in Response.java
 because that file, together with Request.java, is the official definition of the client-server
 protocol, and its documentation.
 */
NSString *const ksoServerNotRespondedYet = @"ServerNotRespondedYet";
NSString *const ksoServerDidNotRespond = @"ServerDidNotRespond";



+ (UIColor *)faultyEmailAddressBackgroundColor
{
    return [UIColor colorWithRed:0xff / 255.0 green:0xd3 / 255.0 blue:0xd2 / 255.0 alpha:0xff / 255.0];
}


@end

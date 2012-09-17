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

NSString *const ksoOnePairJson = @"{\"%@\" : \"%@\"} ";
NSString *const ksoTwoPairsJson = @"{\"%@\" : \"%@\", \"%@\" : \"%@\"} ";
NSString *const ksoThreePairsJson = @"{\"%@\" : \"%@\", \"%@\" : \"%@\", \"%@\" : \"%@\"} ";
NSString *const ksoFourPairsJson = @"{\"%@\" : \"%@\", \"%@\" : \"%@\", \"%@\" : \"%@\", \"%@\" : \"%@\"} ";

NSString *const ksoTwoDictionaries = @"[ \"%@\" : %@, \"%@\" : %@ ]";
NSString *const ksoThreeDictionaries = @"[ \"%@\" : %@, \"%@\" : %@, \"%@\" : %@ ]";


/*
 These constants must match the symbolic names of the server-side enumerations in Request.java
 because that file, together with Response.java, is the official definition of the client-server
 protocol, and its documentation.
 
 These constants are kept in alphabetic order.
 */
NSString *const ksoClientVersion = @"ClientVersion";
NSString *const ksoCreateProject = @"CreateProject";
NSString *const ksoEpic = @"Epic";
NSString *const ksoLastFetch = @"LastFetch";
NSString *const ksoMode = @"Mode";
NSString *const ksoNextPush = @"NextPush";
NSString *const ksoPending = @"Pending";
NSString *const ksoPendingQueue = @"PendingQueue";
NSString *const ksoProjectId = @"ProjectId";
NSString *const ksoProjectList = @"ProjectList";
NSString *const ksoProjectOwnerEmail = @"ProjectOwnerEmail";
NSString *const ksoSecurityToken = @"SecurityToken";
NSString *const ksoSprint = @"Sprint";
NSString *const ksoStory = @"Story";
NSString *const ksoTask = @"Task";
NSString *const ksoToken = @"Token";
NSString *const ksoVersion = @"Version";

// Creating a new project request url is built from the above constants and should be kept in sync with them
NSString *const ksoCreateNewProjectUrl = @"%@?Mode=CreateProject&ProjectOwnerEmail=%@&ProjectId=%@&SecurityToken=%@";

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

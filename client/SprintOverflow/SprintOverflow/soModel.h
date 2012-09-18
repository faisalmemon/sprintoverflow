//
//  soModel.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "soEpic.h"
#import "soProject.h"

/*
 Command line arguments:
 
 When the scheme (in Xcode next to the stop icon to its right; e.g. LocalServer>iPhone 5.1 Simulator) specifies
 arguments, they are picked up by the model as extra data that came from the "environment".  The application understands
 
 -server "local"
 -debug
 
 The server setting of local makes the application use a local instance of Google App Engine as the server.
 The debug setting enables debugging only functionality.  It is intended that this causes an additional tab
 panel to display to allow diagnostics.
 */

@interface soModel : NSObject {
    BOOL isDebug;
    BOOL isLocalServer;
    NSMutableArray *_lastFetch;
    NSMutableArray *_nextPush;
    NSMutableArray *_resolveList;
    NSMutableDictionary *_securityCodes;
}

@property (nonatomic, retain) NSMutableArray *lastFetch;
@property (nonatomic, retain) NSMutableArray *nextPush;
@property (nonatomic, retain) NSMutableArray *resolveList;

+ (id)sharedInstance;
- (BOOL)bootstrap;
-(NSString*)serverUrlPrefix;
-(BOOL)isDebug;

-(void)addEpic:(soEpic*)epic toProject:(soProject*)project;
-(void)dumpEpics;
-(NSString*)securityCodeFromId:(NSString*)project_id FromOwner:(NSString*)owner_email;

- (BOOL)addProjectOwnerEmail:(NSString*)project_owner_email
                      WithID:(NSString*)project_id
           WithSecurityToken:(NSString*)security_token;

@end

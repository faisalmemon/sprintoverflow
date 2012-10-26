//
//  soModel.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "soScreenJumpProtocol.h"

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
    /*
     Threading methodology:
     All variables are marked with:
        MT = Multi-thread access
        ST = Single-thread access
     
     Any access to a group of MT variables must all be locked.
     Any derived data calculation during an update must be locked, e.g. size of structure might change
     
     There is only one lock used, the @self, since the soModel is a system-wide singleton.
     */
    BOOL isDebug; // ST
    BOOL isLocalServer;// ST
    NSMutableArray *_lastFetch;  // MT
    NSMutableArray *_nextPush; // MT
    NSMutableDictionary *_securityCodes; // ST
    id<soScreenJumpProtocol> _delegateScreenJump;
}

@property (nonatomic, retain) NSMutableArray *lastFetch;
@property (nonatomic, retain) NSMutableArray *nextPush;
@property (nonatomic, retain) NSMutableArray *resolveList;
@property (nonatomic, retain) id<soScreenJumpProtocol> delegateScreenJump;

- (void)setAltogetherLastFetch:(NSMutableArray *)lastFetch
                      NextPush:(NSMutableArray *)nextPush;
- (void)getAltogetherLastFetch:(NSMutableArray **)lastFetch
                      NextPush:(NSMutableArray **)nextPush;

+ (id)sharedInstance;
- (BOOL)bootstrap;
-(NSString*)serverUrlPrefix;
-(BOOL)isDebug;

-(void)addEpic:(soEpic*)epic toProject:(soProject*)project;
-(void)dumpEpics;
-(NSString*)securityCodeFromId:(NSString*)project_id FromOwner:(NSString*)owner_email;

- (BOOL)addProjectOwnerEmail:(NSString*)project_owner_email
                      WithID:(NSString*)project_id
           WithSecurityToken:(NSString*)security_token
               WithDiscovery:(NSString*)discovery;

- (BOOL)joinProjectOwnerEmail:(NSString*)project_owner_email
                WithIdOrToken:(NSString*)id_or_token;

- (int)unifiedCount;
- (id)objectAtUnifiedIndex:(int)index;

@end

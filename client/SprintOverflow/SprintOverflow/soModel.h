//
//  soModel.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "soEpic.h"

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
    NSMutableArray *_projects;
    NSMutableArray *_epics;
    NSMutableDictionary *_securityCodes;
}

+ (id)sharedInstance;
-(NSString*)serverUrlPrefix;
-(BOOL)isDebug;
-(void)bootstrapFromServer:(NSString *)modelAsJsonString;
-(void)addEpic:(soEpic*)epic;
-(void)dumpEpics;
-(NSString*)securityCodeFromId:(NSString*)project_id FromOwner:(NSString*)owner_email;

@end

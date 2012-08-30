//
//  soModel.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "soEpic.h"

@interface soModel : NSObject {
    NSMutableArray *_epics;
    NSMutableDictionary *_securityCodes;
}

+ (id)sharedInstance;
-(void)bootstrapFromServer:(NSString *)modelAsJsonString;
-(void)addEpic:(soEpic*)epic;
-(void)dumpEpics;
-(NSString*)securityCodeFromId:(NSString*)project_id FromOwner:(NSString*)owner_email;

@end

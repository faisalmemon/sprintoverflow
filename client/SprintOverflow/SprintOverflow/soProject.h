//
//  soProject.h
//  SprintOverflow
//
//  Created by Faisal Memon on 07/09/2012.
//
//

#import <Foundation/Foundation.h>
#import "soEpic.h"

@interface soProject : NSObject {
    NSString *_projectOwnerEmail;
    NSString *_projectId;
    NSString *_securityToken;
    NSMutableArray *_epics;
}

-(id)initWithOwner:(NSString*)projectOwnerEmail
     withProjectId:(NSString*)projectId
 withSecurityToken:(NSString*)securityToken;

-(void)addEpic:(soEpic *)epic;

-(void)dumpProject;

@property (nonatomic, retain) NSString *projectOwnerEmail;
@property (nonatomic, retain) NSString *projectId;
@property (nonatomic, retain) NSString *securityToken;

@end

//
//  soProject.m
//  SprintOverflow
//
//  Created by Faisal Memon on 07/09/2012.
//
//

#import "soProject.h"

@implementation soProject

@synthesize projectOwnerEmail=_projectOwnerEmail, projectId=_projectId, securityToken=_securityToken;

-(id)initWithOwner:(NSString*)projectOwnerEmail
     withProjectId:(NSString*)projectId
 withSecurityToken:(NSString*)securityToken
{
    self = [super init];
    if (self) {
        _projectOwnerEmail = projectOwnerEmail;
        _projectId = projectId;
        _securityToken = securityToken;
        return self;
    }
    else {
        return nil;
    }
}

-(void)addEpic:(soEpic *)epic;
{
    if (_epics == nil)
    {
        _epics = [[NSMutableArray alloc] init];
    }
    [_epics addObject:epic];
}

-(void)dumpProject
{
    NSLog(@"Dumping project %@ %@ %@", _projectOwnerEmail, _projectId, _securityToken);
    for (soEpic *e in _epics)
    {
        [e dumpEpic];
    }
}

@end

//
//  soModel.m
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSON/JSON.h"

#import "soModel.h"
#import "soEpic.h"
#import "soStory.h"
#import "soTask.h"
#import "soSecurity.h"
#import "soDatabase.h"
#import "soProject.h"

@implementation soModel

+ (id)sharedInstance
{
    static id master = nil;
    
    @synchronized(self)
    {
        if (master == nil) {
            master = [self new];
            [master initFromEnvironment];
        }
            
    }
    
    return master;
}

-(void)initFromEnvironment
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *mode = [standardDefaults stringForKey:@"mode"]; // Not NSLocalizedString
    NSString *server = [standardDefaults stringForKey:@"server"]; // Not NSLocalizedString
    
    if ([mode isEqualToString:@"debug"]) { // Not NSLocalizedString
        isDebug = YES;
    } else {
        isDebug = NO;
    }    
    if ([server isEqualToString:@"local"]) { // Not NSLocalizedString
        isLocalServer = YES;
    } else {
        isLocalServer = NO;
    }
}

-(NSString*)serverUrlPrefix
{
    if (isLocalServer) {
        // we don't retrieve the server url as a setting to avoid security problems due to injecting a bad server
        // url, and to avoid license circumvention to a different server
        return @"http://localhost:8888/sprintoverflow"; // Not NSLocalizedString
    } else {
        return @"http://ios38722.appspot.com/sprintoverflow"; // Not NSLocalizedString
    }
}

-(BOOL)isDebug
{
    return isDebug;
}

-(void)addEpic:(soEpic*)epic toProject:(soProject*)project
{
    [project addEpic:epic];
}

-(void)addProject:(soProject *)project
{
    if (_projects == nil) {
        _projects = [NSMutableArray new];
    }
    
    [_projects addObject:project];
}

-(void)bootstrapFromServer:(NSString *)modelAsJsonString
{
    NSDictionary *top = [modelAsJsonString JSONValue];
    NSDictionary *p = [top objectForKey:@"project"]; // Not NSLocalizedString
    soProject *soproject;
    soproject = [[soProject alloc] initWithOwner:[p objectForKey:@"projectOwnerEmail"] withProjectId:[p objectForKey:@"projectId"] withSecurityToken:[p objectForKey:@"securityToken"]]; // Not NSLocalizedString
    NSArray *epics = [p objectForKey:@"epics"]; // Not NSLocalizedString
    for (NSDictionary *e in epics)
    {
        soEpic *soepic;
        soepic = [[soEpic alloc] initWithName:[e objectForKey:@"epicName"] withId:[e objectForKey:@"epicId"]]; // Not NSLocalizedString
        NSArray *stories = [e objectForKey:@"stories"]; // Not NSLocalizedString
        for (NSDictionary *d in stories)
        {
            soStory *sostory;
            sostory = [[soStory alloc] initWithName:[d objectForKey:@"storyName"] withId:[d objectForKey:@"storyId"] ]; // Not NSLocalizedString
            NSArray *tasks = [d objectForKey:@"tasks"]; // Not NSLocalizedString
            for (NSDictionary *d1 in tasks)
            {
                soTask *sotask;
                sotask = [[soTask alloc] initWithName:[d1 objectForKey:@"taskName"] withId:[d1 objectForKey:@"taskId"] withStatus:[d1 objectForKey:@"status"]]; // Not NSLocalizedString
                [sostory addTask:sotask];
            }
            [soepic addStory:sostory];
        }
        [soproject addEpic:soepic];
    }
    [soproject dumpProject];
}

-(NSString*)securityCodeFromId:(NSString*)project_id FromOwner:(NSString*)owner_email
{
    if (_securityCodes == nil) {
        _securityCodes = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [[NSString alloc] initWithFormat:@"%@:%@", project_id, owner_email]; // Not NSLocalizedString
    NSString *securityCode = [_securityCodes valueForKey:key];
    if (nil == securityCode) {
        securityCode = [soSecurity createSecurityCode];
        soDatabase* database = [soDatabase sharedInstance];
        [database saveAsyncSecurityCodeForProjectID:project_id ForProjectOwnerEmail:owner_email WithToken:securityCode SimulateFailure:soDatabase_saveSecurityToken_NoFailureSimulation];
        [_securityCodes setObject:securityCode forKey:key];
    }
    return securityCode;
}

@end

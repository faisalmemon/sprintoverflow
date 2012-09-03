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
    
    if ([mode isEqualToString:@"debug"]) {
        isDebug = YES;
    } else {
        isDebug = NO;
    }    
    if ([server isEqualToString:@"local"]) {
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

-(void)addEpic:(soEpic *)epic
{
    if (_epics == nil) {
        _epics = [NSMutableArray new];
    }
    
    [_epics addObject:epic];
}

-(void)dumpEpics
{
    NSLog(@"dumpEpics");
    for (soEpic *e in _epics)
    {
        NSLog(@"Dumping epic: %@", e);
        [e dumpEpic];
    }
}

-(void)bootstrapFromServer:(NSString *)modelAsJsonString
{
    NSDictionary *top = [modelAsJsonString JSONValue];
    NSDictionary *m = [top objectForKey:@"epic"]; // Not NSLocalizedString
    
    soEpic *soepic;
    soepic = [[soEpic alloc] initWithName:[m objectForKey:@"epicName"] withId:[m objectForKey:@"epicId"]]; // Not NSLocalizedString

    
    NSArray *stories = [m objectForKey:@"stories"]; // Not NSLocalizedString
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
    

    [self addEpic:soepic];
    [self dumpEpics];
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

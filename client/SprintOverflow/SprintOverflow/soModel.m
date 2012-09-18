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
#import "soConstants.h"
#import "soUtil.h"

@implementation soModel

- (NSMutableArray *)lastFetch
{
    @synchronized(self) {
        return _lastFetch;
    }
}

- (NSMutableArray *)nextPush
{
    @synchronized(self) {
        return _nextPush;
    }
    
}

- (NSMutableArray *)resolveList
{
    @synchronized(self) {
        return _resolveList;
    }
    
}

- (void)setLastFetch:(NSMutableArray *)lastFetch
{
    if (nil == lastFetch) {
        NSLog(@"nil data entering lastFetch");
    }
    @synchronized(self) {
        _lastFetch = lastFetch;
    }
}

- (void)setNextPush:(NSMutableArray *)nextPush
{
    if (nil == nextPush) {
        NSLog(@"nil data entering nextPush");
    }
    @synchronized(self) {
        _nextPush = nextPush;
    }
}

- (void)setResolveList:(NSMutableArray *)resolveList
{
    if (nil == resolveList) {
        NSLog(@"nil data entering resolveList");
    }
    @synchronized(self) {
        _resolveList = resolveList;
    }
}

- (void)setAltogetherLastFetch:(NSMutableArray *)lastFetch
                      NextPush:(NSMutableArray *)nextPush
                   ResolveList:(NSMutableArray *)resolveList
{
    if (nil == lastFetch || nil == nextPush || nil == resolveList) {
        NSLog(@"nil data entering model");
    }
    @synchronized(self) {
        _lastFetch = lastFetch;
        _nextPush = nextPush;
        _resolveList = resolveList;
    }
}

- (void)getAltogetherLastFetch:(NSMutableArray **)lastFetch
                      NextPush:(NSMutableArray **)nextPush
                   ResolveList:(NSMutableArray **)resolveList
{
    if (lastFetch == nil || nextPush == nil || resolveList == nil) {
        NSLog(@"getAltogether passed nil args unexpectedly.  Ignoring");
        return;
    }
    @synchronized(self) {
        *lastFetch = _lastFetch;
        *nextPush = _nextPush;
        *resolveList = _resolveList;
    }
}

+ (id)sharedInstance
{
    static id master = nil;
    
    @synchronized(self)
    {
        if (master == nil) {
            master = [self new];
            [master initFromEnvironment];
            [master createPlaceholders];
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

-(void)createPlaceholders
{
    _nextPush = [[NSMutableArray alloc]init];
    _lastFetch = [[NSMutableArray alloc]init];
    _resolveList = [[NSMutableArray alloc]init];

}

-(NSString*)serverUrlPrefix
{
    if (isLocalServer) {
        // we don't retrieve the server url as a setting to avoid security problems due to injecting a bad server
        // url, and to avoid license circumvention to a different server
        
        // the development server ignores https so use http
        return @"http://localhost:8888/sprintoverflow"; // Not NSLocalizedString
    } else {
        return @"https://ios38722.appspot.com/sprintoverflow"; // Not NSLocalizedString
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
        [self addProjectOwnerEmail:owner_email WithID:project_id WithSecurityToken:securityCode];
        [_securityCodes setObject:securityCode forKey:key];
    }
    return securityCode;
}

- (BOOL)addProjectOwnerEmail:(NSString*)project_owner_email
                      WithID:(NSString*)project_id
           WithSecurityToken:(NSString*)security_token
{
    NSError *error;    
    NSString *addedProjectJson = [NSString stringWithFormat:
                                  ksoThreePairsJson,
                                  ksoProjectOwnerEmail, project_owner_email,
                                  ksoProjectId, project_id,
                                  ksoSecurityToken, security_token];
    
    NSDictionary *dict = [soUtil DictionaryFromJson:addedProjectJson UpdateError:&error];
    if (!error) {
        @synchronized(self) {
            [[self nextPush] insertObject:dict atIndex:[[self nextPush] count]];
        }
        [soDatabase updateAgainstDiskAndServerSimulatingError:soDatabase_NoFailureSimulation];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)bootstrap
{
    [soDatabase uploadFromDiskAndServerSimulatingError:soDatabase_fetchEpicData_NoFailureSimulation];
    return YES;
}

-(void)dumpEpics
{
    // no implementation yet
}

@end

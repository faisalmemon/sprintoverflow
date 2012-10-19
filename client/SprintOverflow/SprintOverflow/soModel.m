//
//  soModel.m
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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

@synthesize delegateScreenJump=_delegateScreenJump;

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


- (void)setAltogetherLastFetch:(NSMutableArray *)lastFetch
                      NextPush:(NSMutableArray *)nextPush
{
    if (nil == lastFetch || nil == nextPush) {
        NSLog(@"nil data entering model");
    }
    @synchronized(self) {
        _lastFetch = lastFetch;
        _nextPush = nextPush;
    }
}

- (void)getAltogetherLastFetch:(NSMutableArray **)lastFetch
                      NextPush:(NSMutableArray **)nextPush
{
    if (lastFetch == nil || nextPush == nil ) {
        NSLog(@"getAltogether passed nil args unexpectedly.  Ignoring");
        return;
    }
    @synchronized(self) {
        *lastFetch = _lastFetch;
        *nextPush = _nextPush;
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

-(NSString*)securityCodeFromId:(NSString*)project_id FromOwner:(NSString*)owner_email
{
    if (_securityCodes == nil) {
        _securityCodes = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [[NSString alloc] initWithFormat:@"%@:%@", project_id, owner_email]; // Not NSLocalizedString
    NSString *securityCode = [_securityCodes valueForKey:key];
    if (nil == securityCode) {
        securityCode = [soSecurity createSecurityCode];
        [_securityCodes setObject:securityCode forKey:key];
    }
    return securityCode;
}

- (BOOL)addProjectOwnerEmail:(NSString*)project_owner_email
                      WithID:(NSString*)project_id
           WithSecurityToken:(NSString*)security_token
{
    NSError *error;
    NSString *safe_project_owner_email = [soUtil jsonSafeStringFromUserInput:project_owner_email];
    NSString *safe_project_id = [soUtil jsonSafeStringFromUserInput:project_id];
    NSString *safe_security_token = [soUtil jsonSafeStringFromUserInput:security_token];

    NSString *addedProjectJson = [NSString stringWithFormat:
                                  ksoThreePairsJson,
                                  ksoProjectOwnerEmail, safe_project_owner_email,
                                  ksoProjectId, safe_project_id,
                                  ksoSecurityToken, safe_security_token];

    NSDictionary *dict = [soUtil DictionaryFromJson:addedProjectJson UpdateError:&error];
    [dict setValue:ksoNO forKey:ksoSoftDelete];
    
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

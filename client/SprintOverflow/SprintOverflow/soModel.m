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

- (int)unifiedCount {
    return [_lastFetch count] + [_nextPush count];
}

- (id)objectAtUnifiedIndex:(int)index {
    @synchronized(self) {
        if (index < 0 || index >= [self unifiedCount]) {
            return nil;
        } else if (index < [_lastFetch count]) {
            return [_lastFetch objectAtIndex:index];
        } else {
            return [_nextPush objectAtIndex:index - [_lastFetch count]];
        }
    }
}

/*
 When any item in LastFetch has the same GenerationId as an item in
 NextPush, then the NextPush item is deleted.  This represents the
 server resolving the request exactly as was seen by the client with
 no subsequent local changes not yet pushed to server.
 
 This must be called from synchronized(self) because it is thread
 unsafe.
 */
- (void)rationalizeNextPushWithLastFetch
{
    for (NSDictionary* dict in _lastFetch)
    {
        NSString *generation = [dict valueForKey:ksoGenerationId];
        if (nil == generation) {
            continue;
        }
        NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
        NSUInteger currentIndex = -1;
        
        for (NSDictionary* dict2 in _nextPush)
        {
            currentIndex++; // first pass of loop sets currentIndex to 0
            NSString *generation2 = [dict valueForKey:ksoGenerationId];
            if (nil == generation2) {
                continue;
            }
            if ([generation compare:generation2] == NSOrderedSame) {
                [indexesToDelete addIndex:currentIndex];
            }
        }
        [_nextPush removeObjectsAtIndexes:indexesToDelete];
    }
}

- (void)setLastFetch:(NSMutableArray *)lastFetch
{
    if (nil == lastFetch) {
        NSLog(@"nil data entering lastFetch");
    }
    @synchronized(self) {
        _lastFetch = lastFetch;
        [self rationalizeNextPushWithLastFetch];
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
        [self rationalizeNextPushWithLastFetch];
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
        securityCode = [soSecurity createRandomCode];
        [_securityCodes setObject:securityCode forKey:key];
    }
    return securityCode;
}

- (BOOL)addProjectOwnerEmail:(NSString*)project_owner_email
                      WithID:(NSString*)project_id
           WithSecurityToken:(NSString*)security_token
               WithDiscovery:(NSString*)discovery
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
    [dict setValue:discovery forKey:ksoDiscoverable];
    [dict setValue:[soSecurity createRandomCode] forKey:ksoGenerationId];
    
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

- (BOOL)joinProjectOwnerEmail:(NSString*)project_owner_email
                WithIdOrToken:(NSString*)id_or_token
{
    NSError *error;
    NSString *safe_project_owner_email = [soUtil jsonSafeStringFromUserInput:project_owner_email];
    NSString *safe_id_or_token = [soUtil jsonSafeStringFromUserInput:id_or_token];
    
    NSString *joinProjectJson = [NSString stringWithFormat:
                                  ksoThreePairsJson,
                                  ksoProjectOwnerEmail, safe_project_owner_email,
                                  ksoIdOrToken, safe_id_or_token,
                                  ksoJoinProject, ksoYES];

    NSDictionary *dict = [soUtil DictionaryFromJson:joinProjectJson UpdateError:&error];
    [dict setValue:[soSecurity createRandomCode] forKey:ksoGenerationId];

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

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

@implementation soModel

+ (id)sharedInstance
{
    static id master = nil;
    
    @synchronized(self)
    {
        if (master == nil)
            master = [self new];
    }
    
    return master;
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
    NSDictionary *m = [top objectForKey:@"epic"];
    
    soEpic *soepic;
    soepic = [[soEpic alloc] initWithName:[m objectForKey:@"epicName"] withId:[m objectForKey:@"epicId"]];
    
    NSArray *stories = [m objectForKey:@"stories"];
    for (NSDictionary *d in stories)
    {
        soStory *sostory;
        sostory = [[soStory alloc] initWithName:[d objectForKey:@"storyName"] withId:[d objectForKey:@"storyId"] ];
        NSArray *tasks = [d objectForKey:@"tasks"];
        for (NSDictionary *d1 in tasks)
        {
            soTask *sotask;
            sotask = [[soTask alloc] initWithName:[d1 objectForKey:@"taskName"] withId:[d1 objectForKey:@"taskId"] withStatus:[d1 objectForKey:@"status"]];
            [sostory addTask:sotask];
        }
        [soepic addStory:sostory];
        
    }
    

    [self addEpic:soepic];
    [self dumpEpics];
}

@end

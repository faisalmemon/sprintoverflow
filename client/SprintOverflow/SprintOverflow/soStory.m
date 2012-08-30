//
//  soStory.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "soStory.h"
#import "soTask.h"

@implementation soStory

@synthesize storyId, storyName, storyTasks;

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
        withTasks:(NSArray *) tasks
{
    self = [super init];
    if (self) {
        self.storyName = name;
        self.storyId = Id;
        self.storyTasks = [[NSMutableArray alloc] initWithArray:tasks];
        return self;
    } else {
        return nil;
    }
}

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
{
    self.storyName = name;
    self.storyId = Id;
    
    return self;
}

-(void)addTask:(soTask *)task
{
    if (self.storyTasks == nil)
    {
        self.storyTasks = [[NSMutableArray alloc] init];
    }
    [self.storyTasks addObject:task];
}

-(void)dumpStory
{
    NSLog(@"storyId %@ storyName %@ tasks %@", self.storyId, self.storyName, self.storyTasks);
    for (soTask *sotask in self.storyTasks)
    {
        [sotask dumpTask];
    }
}
@end
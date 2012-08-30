//
//  soEpic.m
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "soEpic.h"

@implementation soEpic

@synthesize epicId, epicName, epicStories;

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
      withStories:(NSArray *) stories
{
    self = [super init];
    if (self) {
        self.epicName = name;
        self.epicId = Id;
        self.epicStories = [[NSMutableArray alloc] initWithArray:stories];
        return self;
    }
    else {
        return nil;
    }
}

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
{
    self.epicName = name;
    self.epicId = Id;
    
    return self;
}

-(void)addStory:(soStory *)story
{
    if (self.epicStories == nil)
    {
        self.epicStories = [[NSMutableArray alloc] init];
    }
    [self.epicStories addObject:story];
}

-(void)dumpEpic
{
    NSLog(@"epicId %@ epicName %@ stories %@", self.epicId, self.epicName, self.epicStories);
    for (soStory *sostory in self.epicStories)
    {
        [sostory dumpStory];
    }
}
@end

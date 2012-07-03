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
    self.epicName = name;
    self.epicId = Id;
    self.epicStories = [[NSMutableArray alloc] initWithArray:stories];
    
    return self;
}

-(void)dumpEpic
{
    NSLog(@"epicId %@ epicName %@ stories %@", self.epicId, self.epicName, self.epicStories);
}
@end

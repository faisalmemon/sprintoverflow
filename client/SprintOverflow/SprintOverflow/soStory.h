//
//  soStory.h
//  SprintOverflow
//
//  Created by Faisal Memon on 03/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "soTask.h"

@interface soStory : NSObject {
}

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
        withTasks:(NSArray *)tasks;

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id;

-(void)addTask:(soTask *)task;

-(void)dumpStory;

@property (nonatomic, retain) NSString *storyName;
@property (nonatomic, retain) NSNumber *storyId;
@property (nonatomic, retain) NSMutableArray *storyTasks;

@end

//
//  soTask.m
//  SprintOverflow
//
//  Created by Faisal Memon on 03/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "soTask.h"

@implementation soTask

@synthesize taskId, taskName, status;


-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
       withStatus:(NSString *)suppliedStatus
{
    self.taskName = name;
    self.taskId = Id;
    self.status = suppliedStatus;
    
    return self;

}

-(void)dumpTask
{
    NSLog(@"taskId %@ taskName %@ status %@", self.taskId, self.taskName, self.status);
}


@end

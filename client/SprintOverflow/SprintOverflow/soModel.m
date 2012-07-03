//
//  soModel.m
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "soModel.h"
#import "soEpic.h"

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
@end

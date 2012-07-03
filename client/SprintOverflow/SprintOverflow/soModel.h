//
//  soModel.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "soEpic.h"

@interface soModel : NSObject {
    NSMutableArray *_epics;
}

+ (id)sharedInstance;
-(void)addEpic:(soEpic*)epic;
-(void)dumpEpics;

@end

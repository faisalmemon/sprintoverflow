//
//  soTask.h
//  SprintOverflow
//
//  Created by Faisal Memon on 03/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  soTask.h
//  SprintOverflow
//
//  Created by Faisal Memon on 03/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface soTask : NSObject {
}

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
       withStatus:(NSString *)status;

-(void)dumpTask;

@property (nonatomic, retain) NSString *taskName;
@property (nonatomic, retain) NSNumber *taskId;
@property (nonatomic, retain) NSString *status;

@end

//
//  soEpic.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface soEpic : NSObject {
}

-(id)initWithName:(NSString *)name
           withId:(NSNumber *)Id
      withStories:(NSArray *)stories;

-(void)dumpEpic;

@property (nonatomic, retain) NSString *epicName;
@property (nonatomic, retain) NSNumber *epicId;
@property (nonatomic, retain) NSMutableArray *epicStories;

@end

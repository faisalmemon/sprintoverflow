//
//  LocalModelCache.h
//  SprintOverflow
//
//  Created by Faisal Memon on 10/07/2012.
//  Copyright (c) 2012 Perivale Software Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalModelCache : NSManagedObject

@property (nonatomic, retain) NSDate * timeOfFetch;
@property (nonatomic, retain) NSString * fetchUrl;
@property (nonatomic, retain) NSString * responseJson;

@end

//
//  LocalModelCache.h
//  SprintOverflow
//
//  Created by Faisal Memon on 30/08/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalModelCache : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * serverResponse;
@property (nonatomic, retain) NSDate * time;

@end

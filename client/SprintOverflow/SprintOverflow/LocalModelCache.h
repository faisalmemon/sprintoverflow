//
//  LocalModelCache.h
//  SprintOverflow
//
//  Created by Faisal Memon on 13/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalModelCache : NSManagedObject

@property (nonatomic, retain) NSString * serverResponse;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * url;

@end

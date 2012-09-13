//
//  PendingQueue.h
//  SprintOverflow
//
//  Created by Faisal Memon on 13/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PendingQueue : NSManagedObject

@property (nonatomic, retain) NSNumber * itemNumber;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSString * outcome;
@property (nonatomic, retain) NSString * pendingUrl;

@end

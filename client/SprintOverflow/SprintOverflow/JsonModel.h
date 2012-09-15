//
//  JsonModel.h
//  SprintOverflow
//
//  Created by Faisal Memon on 15/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JsonModel : NSManagedObject

@property (nonatomic, retain) NSString * projectList;
@property (nonatomic, retain) NSString * lastFetch;
@property (nonatomic, retain) NSString * pendingQueue;

@end

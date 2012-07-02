//
//  soDatabase.h
//  SprintOverflow
//
//  Created by Faisal Memon on 17/05/2012.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSON.h"

@interface soDatabase : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+(void)populateBootstrapData;
+(void)fetchEpicData:(NSString *)forUser;
+ (id)sharedInstance;
+(NSArray *)stories:(int)withStatus;

@end

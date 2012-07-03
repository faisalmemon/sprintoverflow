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

#import "soModel.h"

@interface soDatabase : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+(BOOL)      fetchEpicData:(NSString *)forUser;
+(id)        sharedInstance;

@end

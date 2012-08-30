//
//  soDatabase.h
//  SprintOverflow

// The soDatabase module owns the interaction with the server, and the interaction with
// the data store.  The data store is used as a persistent cache for the server protocol
// so that if the server is unavailable, the data is persisted locally until we are online
// again.
//
// As a design rule, this only this module may have asynchronous behaviour.  We use a single
// serial dispatch queue for simplicity.
//
//  Created by Faisal Memon on 17/05/2012.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSON.h"

#import "soModel.h"

#define SO_SERVER_PROTOCOL_QUEUE_NAME "com.perivalebluebell.SprintOverflow.0"
#define SO_QUEUE_ERROR 1

extern const int soDatabase_fetchEpicData_NoFailureSimulation;
extern const int soDatabase_fetchEpicData_SimulateNetworkDown;

@interface soDatabase : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    dispatch_queue_t queue;
}

- (void)fetchEpicDataAsyncForUser:(NSString*)for_user;
- (void)fetchEpicDataAsyncForUser:(NSString*)for_user SimulateFailure:(int)simulate_failure;
+(BOOL)fetchEpicDataForUser:(NSString *)forUser;
+(BOOL)fetchEpicDataForUser:(NSString *)forUser SimulateFailure:(int)simulateFailure;
+(id)        sharedInstance;

@end

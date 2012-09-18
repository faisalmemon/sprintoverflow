//
//  soDatabase.h
//  SprintOverflow

// The soDatabase module owns the interaction with the server, and the interaction with
// the data store.  The data store is used as a persistent cache for the server protocol
// so that if the server is unavailable, the data is persisted locally until we are online
// again.
//
// As a design rule, only this module may have asynchronous behaviour.  We use a single
// serial dispatch queue for top level change requests, and beneath that, use an operation
// queue for network callbacks.
//
//  Created by Faisal Memon on 17/05/2012.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSON.h"

#import "soModel.h"

#define SO_SQLITE_DATABASE_NAME         "sprintoverflow0.sqlite"
#define SO_SERVER_PROTOCOL_QUEUE_NAME   "com.perivalebluebell.SprintOverflow.0"
#define SO_QUEUE_ERROR                  1
#define SO_CORE_DATA_ERROR              2
#define SO_JSON_ERROR                   3

extern const int soDatabase_NoFailureSimulation;
extern const int soDatabase_fetchEpicData_NoFailureSimulation;
extern const int soDatabase_fetchEpicData_SimulateNetworkDown;
extern const int soDatabase_saveSecurityToken_NoFailureSimulation;

@interface soDatabase : NSObject {
    NSManagedObjectModel                *managedObjectModel;
    NSManagedObjectContext              *managedObjectContext;
    NSPersistentStoreCoordinator        *persistentStoreCoordinator;
    dispatch_queue_t                    queue;
    NSOperationQueue                    *_networkQueue;
    NSMutableData                       *receivedData;
}

+ (id)                                  sharedInstance;

+ (void)updateAgainstDiskAndServerSimulatingError:(int)simulate_failure;
+ (void)uploadFromDiskAndServerSimulatingError:(int)simulate_failure;

@end

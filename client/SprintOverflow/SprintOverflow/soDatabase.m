//
//  soDatabase.m
//  SprintOverflow
//
//  Created by Faisal Memon on 17/05/2012.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "soDatabase.h"
#import "LocalModelCache.h"

const int soDatabase_fetchEpicData_NoFailureSimulation = 0;
const int soDatabase_fetchEpicData_SimulateNetworkDown = 1;


@implementation soDatabase

+ (id)sharedInstance
{
	static id master = nil;
	
	@synchronized(self)
	{
		if (master == nil)
			master = [self new];
	}
    
    return master;
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
                        NSLocalizedString(@"Error", @"Title for alert displayed when a system, download, server, or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)databasePath
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"sprintoverflow0.sqlite"];
}

- (id)init
{
    self = [super init];
    if (self) {
        queue = dispatch_queue_create(SO_SERVER_PROTOCOL_QUEUE_NAME, NULL);
        if (NULL == queue) {
            NSDictionary *userInfo =
            [NSDictionary dictionaryWithObject: NSLocalizedString(@"System Queue Error.  A core system service is not available; perhaps shutdown other applications.  Going into offline mode.", @"Error message displayed when system could not provide a core system service for queuing.")
                                        forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"System" code:SO_QUEUE_ERROR userInfo:userInfo];
            [self handleError:error];
        }
    }
    return self;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSString	*path = [self databasePath];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
	
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
	
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (void)fetchEpicDataAsyncForUser:(NSString*)for_user
{
    [self fetchEpicDataAsyncForUser:for_user SimulateFailure:soDatabase_fetchEpicData_NoFailureSimulation];
}

- (void)fetchEpicDataAsyncForUser:(NSString*)for_user SimulateFailure:(int)simulate_failure
{
    if (!queue) {
        return;
    }
    
    dispatch_async(queue, ^{
        [soDatabase fetchEpicDataForUser:for_user SimulateFailure:simulate_failure];
    });
}

+(BOOL)fetchEpicDataForUser:(NSString *)forUser
{
    return [soDatabase fetchEpicDataForUser:forUser SimulateFailure:soDatabase_fetchEpicData_NoFailureSimulation];
}

+(BOOL)fetchEpicDataForUser:(NSString *)forUser SimulateFailure:(int)simulateFailure
{
    soDatabase *instance = [soDatabase sharedInstance];    
    NSManagedObjectContext* mocp = [instance managedObjectContext];
    
    // Construct a Google Application Engine API request.
    // http://ios38722.appspot.com/barebones?Mode=Epic&User=JayRandomHacker
    //
    NSString *urlString = [NSString stringWithFormat:@"http://ios38722.appspot.com/sprintoverflow?Mode=Epic&User=%@", forUser];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *jsonString = nil;
    
    // Get the contents of the URL as a string except for simulations of network down
    if (simulateFailure != soDatabase_fetchEpicData_SimulateNetworkDown) {
        jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    }
    
    if (jsonString == nil) {
        // Try to get the most recent result cached locally
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalModelCache" inManagedObjectContext:mocp];
        [request setEntity:entity];
        
        // Order the events by fetch date, most recent first.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeOfFetch" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fetchUrl like %@", urlString];
        [request setPredicate:predicate];
        
        // Execute the fetch -- create a mutable copy of the result.
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[mocp executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResults == nil || 0 >= [mutableFetchResults count]) {
            NSLog(@"Could not fetch epic data from the network or a local cache.  Need to start off with blank setup.");
            return FALSE;
        }
        jsonString = [[mutableFetchResults objectAtIndex:0] responseJson];
        
    } else {
        // Store the result of the query in the local cache
        LocalModelCache *cache;
        NSError *error = nil;
        cache = (LocalModelCache *)[NSEntityDescription insertNewObjectForEntityForName:@"LocalModelCache" inManagedObjectContext:mocp];
        
        [cache setFetchUrl:urlString];
        [cache setTimeOfFetch:[NSDate date]];
        [cache setResponseJson:jsonString];
        [mocp save:&error];
        NSLog(@"Saving a local model cache, error object is %@", error);
    }                                                     
        
    soModel *theModel = [soModel sharedInstance];
    [theModel bootstrapFromServer:jsonString];
    
    return TRUE;

}
@end

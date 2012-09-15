//
//  soDatabase.m
//  SprintOverflow
//
//  Created by Faisal Memon on 17/05/2012.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "soDatabase.h"
#import "LocalModelCache.h"
#import "soUtil.h"
#import "soConstants.h"
#import "ProjectList.h"
#import "PendingQueue.h"
#import "JsonModel.h"

const int soDatabase_fetchEpicData_NoFailureSimulation = 0;
const int soDatabase_fetchEpicData_SimulateNetworkDown = 1;
const int soDatabase_saveSecurityToken_NoFailureSimulation = 2;


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
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error", @"Title for alert displayed when a system, download, server, or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", @"Acknowledge the alert message")
                     otherButtonTitles:nil];

    
    __block BOOL didRunBlock = NO;
    void (^blockInTheMainThread)(void) = ^(void) {
        NSLog(@"on main thread!");
        [alertView show];
        didRunBlock = YES;
    };
    
    if (currentQueue == mainQueue) {
        blockInTheMainThread();
    } else {
        dispatch_sync(mainQueue, blockInTheMainThread);
    }
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)databasePath
{
    NSString *databaseName = [[NSString alloc] initWithCString:SO_SQLITE_DATABASE_NAME encoding:NSUTF8StringEncoding];
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent: databaseName];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self dispatchQueue];
        [self networkQueue];
    }
    return self;
}

-(NSOperationQueue*) networkQueue
{
    @synchronized(self) {
        if (NULL == _networkQueue) {
            _networkQueue = [NSOperationQueue new];
        }
    }
    return _networkQueue;
}
- (dispatch_queue_t) dispatchQueue
{
    @synchronized(self) {
        if (NULL == queue) {
            queue = dispatch_queue_create(SO_SERVER_PROTOCOL_QUEUE_NAME, NULL);
        }
    }
    if (NULL == queue) {
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject: NSLocalizedString(@"System Queue Error.  A core system service is not available; perhaps shutdown other applications.  Going into offline mode.", @"Error message displayed when system could not provide a core system service for queuing.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"System" code:SO_QUEUE_ERROR userInfo:userInfo]; // Not NSLocalizedString
        [self handleError:error];
    }
    return queue;
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
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject: NSLocalizedString(@"Local Persistent Store Problem.  This application has problems accessing its local data store.  The server will however have the official copy.  This can occur during faulty client or server upgrades or system failures.  The resolution is to uninstall and reinstall this application whilst good network access and battery levels are present.", @"Error message displayed when system could not access its internal local data store.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"ApplicationCoreData" code:SO_CORE_DATA_ERROR userInfo:userInfo]; // Not NSLocalizedString
        [self handleError:error];
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        persistentStoreCoordinator = nil;
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
        return managedObjectContext;

    }
    return nil;
}

- (void)fetchEpicDataAsyncForUser:(NSString*)for_user
{
    [self fetchEpicDataAsyncForUser:for_user SimulateFailure:soDatabase_fetchEpicData_NoFailureSimulation];
}

- (void)fetchEpicDataAsyncForUser:(NSString*)for_user SimulateFailure:(int)simulate_failure
{
    if (![self dispatchQueue]) {
        return;
    }
    
    dispatch_async(queue, ^{
        [soDatabase fetchEpicDataForUser:for_user SimulateFailure:simulate_failure];
    });
}

- (void)saveAsyncSecurityCodeForProjectID:(NSString*)project_id
                     ForProjectOwnerEmail:(NSString *)project_owner_email
                                WithToken:(NSString*)security_token
{
    [self createNewProjectForProjectID:project_id ForProjectOwnerEmail:project_owner_email WithToken:security_token SimulateFailure:soDatabase_saveSecurityToken_NoFailureSimulation];
}

- (void)createNewProjectForProjectID:(NSString*)project_id
                     ForProjectOwnerEmail:(NSString *)project_owner_email
                                WithToken:(NSString*)security_token
                          SimulateFailure:(int)simulate_failure
{
    if (![self dispatchQueue]) {
        return;
    }
    
    dispatch_async(queue, ^{
        [soDatabase createNewProject:project_id ForProjectOwnerEmail:project_owner_email WithToken:security_token SimulateFailure:simulate_failure];
    });
}

-(int)getNextFreePendingQueueItemNumber
{
    NSManagedObjectContext* mocp = [self managedObjectContext];
    if (nil == mocp) {
        return 0;
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PendingQueue" inManagedObjectContext:mocp]; // Not NSLocalizedString
    [request setEntity:entity];
    
    // Order the events by fetch date, most recent first.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemNumber" ascending:NO]; // Not NSLocalizedString
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Execute the fetch -- create a mutable copy of the result.
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[mocp executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil || 0 >= [mutableFetchResults count]) {
        return 0;  // We have no items in the pending queue
    } else {
        PendingQueue *pq = [mutableFetchResults objectAtIndex:0];
        return 1 + [[pq itemNumber] intValue];
    }
}

-(BOOL) addToProjectListProjectOwner:(NSString*)project_owner_email WithID:(NSString*)project_id WithSecurityToken:(NSString*)security_token
{
    NSError *error;
    soModel *model = [soModel sharedInstance];
    NSManagedObjectContext* mocp = [self managedObjectContext];
    if (nil == mocp) {
        return NO;
    }

    NSString *addedProjectJson = [NSString stringWithFormat:
                                  @"{\"%@\" : \"%@\", \"%@\" : \"%@\", \"%@\" : \"%@\"} ", // Not NSLocalizedString
                                  ksoProjectOwnerEmail, project_owner_email,
                                  ksoProjectId, project_id,
                                  ksoSecurityToken, security_token];
    

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[addedProjectJson UTF8String] length:[addedProjectJson length]] options:NSJSONReadingMutableContainers error:&error];
    
    [[model projects] insertObject:dict atIndex:0];
    
    JsonModel *jsonModel;
    jsonModel = (JsonModel*)[NSEntityDescription insertNewObjectForEntityForName:@"ProjectList" inManagedObjectContext:mocp]; // Not NSLocalizedString
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JsonModel" inManagedObjectContext:mocp]; // Not NSLocalizedString
    [request setEntity:entity];
    NSMutableArray *mutableFetchResults = [[mocp executeFetchRequest:request error:&error] mutableCopy];
    
    JsonModel *projectList;
    
    if ([mutableFetchResults count] == 0) {
        projectList = (JsonModel*)[NSEntityDescription insertNewObjectForEntityForName:@"JsonModel" inManagedObjectContext:mocp]; // Not NSLocalizedString
    } else {
        projectList = [mutableFetchResults objectAtIndex:0];
    }

    
    NSData *revisedProjectList = [NSJSONSerialization dataWithJSONObject:[model projects]options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *revisedProjectListAsString = [NSString stringWithUTF8String:[revisedProjectList bytes]];

    [projectList setProjectList:revisedProjectListAsString];    
    [mocp save:&error];
    return YES;  // newly added to the project interest list
    
   
}

- (BOOL)pendingQueueNewProjectOwnerEmail:(NSString*)project_owner_email WithID:(NSString*)project_id WithSecurityToken:(NSString*)security_token
{
    NSManagedObjectContext* mocp = [self managedObjectContext];
    if (nil == mocp) {
        return NO;
    }
    int nextFreePendingQueueItemNumber = [self getNextFreePendingQueueItemNumber];
    NSLog(@"next free pending queue item number is %d", nextFreePendingQueueItemNumber);
    NSString *urlString =
    [NSString stringWithFormat:ksoCreateNewProjectUrl,
     [[soModel sharedInstance ] serverUrlPrefix],
     [soUtil safeWebStringFromString:project_owner_email],
     [soUtil safeWebStringFromString:project_id],
     [soUtil safeWebStringFromString:security_token]];
    PendingQueue *pendingQueue;
    NSError *error = nil;
    pendingQueue = (PendingQueue*)[NSEntityDescription insertNewObjectForEntityForName:@"PendingQueue" inManagedObjectContext:mocp]; // Not NSLocalizedString
    
    [pendingQueue setItemNumber:[NSNumber numberWithInt:nextFreePendingQueueItemNumber] ];
    [pendingQueue setPendingUrl:urlString];
    [pendingQueue setAction:NSLocalizedString(@"Add a new project", @"Description used when the user is reviewing what pending actions are present")];
    [pendingQueue setOutcome:ksoPending];
    
    [mocp save:&error];
    return YES;
}

-(BOOL)syncWithServer
{
    soModel *model = [soModel sharedInstance];
    NSManagedObjectContext* mocp = [self managedObjectContext];
    if (nil == mocp) {
        return NO;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JsonModel" inManagedObjectContext:mocp]; // Not NSLocalizedString
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[mocp executeFetchRequest:request error:&error] mutableCopy];
    
    NSString *projectList = [mutableFetchResults objectAtIndex:0];
    
    NSData *projectListAsJson = [NSJSONSerialization dataWithJSONObject:projectList options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableArray *result = [NSJSONSerialization JSONObjectWithData:projectListAsJson options:NSJSONReadingMutableContainers error:&error];
    
    // In body data for the 'application/x-www-form-urlencoded' content type,
    // form fields are separated by an ampersand. Note the absence of a
    // leading ampersand or question mark.
    NSString *bodyData = @"Mode=PostTest";
  
    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[model serverUrlPrefix]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];

    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:[bodyData length]]];
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *resp, NSData *data, NSError *error) {
        NSString* fromServer = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"Server responded with %@", fromServer);
    };
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[self networkQueue] completionHandler:handler];

    return YES;
}

+(BOOL)createNewProject:(NSString*)project_id ForProjectOwnerEmail:(NSString*)project_owner_email WithToken:(NSString*)security_token SimulateFailure:(int)simulateFailure
{
    soDatabase *instance = [soDatabase sharedInstance];
    
    NSManagedObjectContext* mocp = [instance managedObjectContext];
    if (nil == mocp) {
        return NO;
    }
    
    [instance addToProjectListProjectOwner:project_owner_email WithID:project_id WithSecurityToken:security_token];
    
    [instance pendingQueueNewProjectOwnerEmail:project_owner_email WithID:project_id WithSecurityToken:security_token];
    
    [instance syncWithServer];
    
    return YES;
}

+(BOOL)fetchEpicDataForUser:(NSString *)forUser
{
    return [soDatabase fetchEpicDataForUser:forUser SimulateFailure:soDatabase_fetchEpicData_NoFailureSimulation];
}

+(BOOL)fetchEpicDataForUser:(NSString *)forUser SimulateFailure:(int)simulateFailure
{
    soDatabase *instance = [soDatabase sharedInstance];    
    NSManagedObjectContext* mocp = [instance managedObjectContext];
    if (nil == mocp) {
        return NO;
    }
    soModel *model = [soModel sharedInstance];
    
    // Construct a Google Application Engine API request.

    NSString *urlString = [NSString stringWithFormat:@"%@?Mode=Epic&User=%@", [model serverUrlPrefix], forUser]; // Not NSLocalizedString
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *jsonString = nil;
    
    // Get the contents of the URL as a string except for simulations of network down
    if (simulateFailure != soDatabase_fetchEpicData_SimulateNetworkDown) {
        jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    }
    
    if (jsonString == nil) {
        // Try to get the most recent result cached locally
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalModelCache" inManagedObjectContext:mocp]; // Not NSLocalizedString
        [request setEntity:entity];
        
        // Order the events by fetch date, most recent first.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO]; // Not NSLocalizedString

        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url like %@", urlString]; // Not NSLocalizedString

        [request setPredicate:predicate];
        
        // Execute the fetch -- create a mutable copy of the result.
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[mocp executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResults == nil || 0 >= [mutableFetchResults count]) {
            NSLog(@"Could not fetch epic data from the network or a local cache.  Need to start off with blank setup.");
            return FALSE;
        }
        jsonString = [[mutableFetchResults objectAtIndex:0] serverResponse];
        
    } else {
        // Store the result of the query in the local cache
        LocalModelCache *cache;
        NSError *error = nil;
        cache = (LocalModelCache *)[NSEntityDescription insertNewObjectForEntityForName:@"LocalModelCache" inManagedObjectContext:mocp]; // Not NSLocalizedString
        
        [cache setUrl:urlString];
        [cache setTime:[NSDate date]];
        [cache setServerResponse:jsonString];
        [mocp save:&error];
        NSLog(@"Saving a local model cache, error object is %@", error);
    }                                                     
        
    soModel *theModel = [soModel sharedInstance];
    [theModel bootstrapFromServer:jsonString];
    
    return YES;

}
@end

#ifdef USE_OLD_CODE_FRAGMENT_TO_TALK_TO_SERVER
NSString *urlString =
[NSString stringWithFormat:ksoCreateNewProjectUrl,
 [[soModel sharedInstance ] serverUrlPrefix],
 [soUtil safeWebStringFromString:project_owner_email],
 [soUtil safeWebStringFromString:project_id],
 [soUtil safeWebStringFromString:security_token]];
NSString *serverResponse = ksoServerNotRespondedYet;

// Store the request in the local cache
LocalModelCache *cache;
NSError *error = nil;
cache = (LocalModelCache *)[NSEntityDescription insertNewObjectForEntityForName:@"LocalModelCache" inManagedObjectContext:mocp]; // Not NSLocalizedString

[cache setUrl:urlString];
[cache setTime:[NSDate date]];
[cache setServerResponse:serverResponse];
[mocp save:&error];
NSLog(@"Saving a local model cache, error object is %@", error);

NSURL *url = [NSURL URLWithString:urlString];
NSString *response;
if (simulateFailure == soDatabase_saveSecurityToken_NoFailureSimulation) {
    response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
} else {
    response = ksoServerDidNotRespond;
}
[cache setServerResponse:response];
[mocp save:&error];
return TRUE;
#endif

//
//  soDatabase.m
//  SprintOverflow
//
//  Created by Faisal Memon on 17/05/2012.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "soDatabase.h"
#import "soUtil.h"
#import "soConstants.h"
#import "ProjectList.h"
#import "JsonModel.h"

const int soDatabase_NoFailureSimulation = 0;
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
        NSLog(@"on main thread so we can show an alert");
        [alertView show];
        didRunBlock = YES;
    };
    
    if (currentQueue == mainQueue) {
        blockInTheMainThread();
    } else {
        dispatch_sync(mainQueue, blockInTheMainThread);
    }
}


- (void)dispatchQueueProblem
{
    NSDictionary *userInfo =
    [NSDictionary dictionaryWithObject: NSLocalizedString(@"System Queue Error.  A core system service is not available; perhaps shutdown other applications.  Going into offline mode.", @"Error message displayed when system could not provide a core system service for queuing.")
                                forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"System" code:SO_QUEUE_ERROR userInfo:userInfo]; // Not NSLocalizedString
    [self handleError:error];
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
}

- (void)inMemoryConsistencyProblem
{
    NSDictionary *userInfo =
    [NSDictionary dictionaryWithObject: NSLocalizedString(@"Local Memory Store Problem.  This application has problems validating its memory store when saving to persistent storage.  The server will however have the official copy.  This can occur during faulty client or server upgrades or system failures.  The resolution is to uninstall and reinstall this application whilst good network access and battery levels are present.", @"Error message displayed when system could not validate its in memory store when attempting to save it to persistent store.")
                                forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"ApplicationCoreData" code:SO_MEMORY_MODEL_ERROR userInfo:userInfo]; // Not NSLocalizedString
    [self handleError:error];
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

    
}
- (void)persistentStoreProblem
{
    NSDictionary *userInfo =
    [NSDictionary dictionaryWithObject: NSLocalizedString(@"Local Persistent Store Problem.  This application has problems accessing its local data store.  The server will however have the official copy.  This can occur during faulty client or server upgrades or system failures.  The resolution is to uninstall and reinstall this application whilst good network access and battery levels are present.", @"Error message displayed when system could not access its internal local data store.")
                                forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"ApplicationCoreData" code:SO_CORE_DATA_ERROR userInfo:userInfo]; // Not NSLocalizedString
    [self handleError:error];
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
}

- (void)jsonProblem
{
    NSDictionary *userInfo =
    [NSDictionary dictionaryWithObject: NSLocalizedString(@"Json Serialization Problem.  This application has problems performaing a data conversion.  This can occur when unacceptable character codes are seen as passed in from the user interface but were not validated, or caught, due to a bug in this program.  The resolution is to revise any recent text data updates.", @"Error message displayed when system could not process text from the user unexpectedly.")
                                forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"ApplicationJsonSerialization" code:SO_JSON_ERROR userInfo:userInfo]; // Not NSLocalizedString
    [self handleError:error];
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
}

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

- (NSOperationQueue*)networkQueue
{
    @synchronized(self) {
        if (NULL == _networkQueue) {
            _networkQueue = [NSOperationQueue new];
        }
    }
    return _networkQueue;
}

- (dispatch_queue_t)dispatchQueue
{
    @synchronized(self) {
        if (NULL == queue) {
            queue = dispatch_queue_create(SO_SERVER_PROTOCOL_QUEUE_NAME, NULL);
        }
    }
    if (NULL == queue) {
        [self dispatchQueueProblem];
    }
    return queue;
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSString	*path = [self databasePath];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
	
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        [self persistentStoreProblem];
        persistentStoreCoordinator = nil;
    }
	
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
	
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

+ (void)updateAgainstDiskAndServerSimulatingError:(int)simulate_failure
{
    soDatabase* instance = [soDatabase sharedInstance];
    if (![instance dispatchQueue]) {
        return;
    }
    
    dispatch_async([instance dispatchQueue], ^{
        [soDatabase queuedUpdateDiskAndServerSimulatingFailure:simulate_failure];
    });

}

+ (void)uploadFromDiskAndServerSimulatingError:(int)simulate_failure
{
    soDatabase* instance = [soDatabase sharedInstance];
    if (![instance dispatchQueue]) {
        return;
    }
    
    dispatch_async([instance dispatchQueue], ^{
        [soDatabase queuedUploadFromDiskAndServerSimulatingError:simulate_failure];
    });
}

-(BOOL)saveMemoryToDisk
{
    NSError *error = nil;
    soModel *model = [soModel sharedInstance];
    NSManagedObjectContext* mocp = [self managedObjectContext];
    if (nil == mocp) {
        return NO;
    }

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JsonModel" inManagedObjectContext:mocp]; // Not NSLocalizedString
    [request setEntity:entity];
    NSMutableArray *mutableFetchResults = [[mocp executeFetchRequest:request error:&error] mutableCopy];
    if (nil != error) {
        [self persistentStoreProblem];
        return NO;
    }
    JsonModel *jsonModel;
    
    if ([mutableFetchResults count] == 0) {
        jsonModel = (JsonModel*)[NSEntityDescription insertNewObjectForEntityForName:@"JsonModel" inManagedObjectContext:mocp]; // Not NSLocalizedString
    } else {
        jsonModel = [mutableFetchResults objectAtIndex:0];
    }
    
    if ([model lastFetch] != nil) {
        NSData *lastFetchData = [NSJSONSerialization dataWithJSONObject:[model lastFetch] options:NSJSONWritingPrettyPrinted error:&error];
        
        if ([lastFetchData length] <=0 || error != nil) {
            NSLog(@"Programming error since last fetch data should never be nil or have serialization problems.");
            [self inMemoryConsistencyProblem];
            return NO;
        }
        NSString *lastFetchDataAsString = [soUtil getUtf8StringFromNsData:lastFetchData UpdateError:&error];
        if (nil != lastFetchDataAsString && nil == error) {
            [jsonModel setLastFetch:lastFetchDataAsString];
        }
        else {
            [jsonModel setLastFetch:ksoEmptyList];
        }
    } else {
        [jsonModel setLastFetch:ksoEmptyList];
    }

    if ([model nextPush] != nil) {
        NSData *nextPushData = [NSJSONSerialization dataWithJSONObject:[model nextPush] options:NSJSONWritingPrettyPrinted error:&error];
        
        if ([nextPushData length] <= 0 || error != nil) {
            NSLog(@"Programming error since push data should never be nil or have serialization problems.");
            [self inMemoryConsistencyProblem];
            return NO;
        }
        NSString *nextPushDataAsString = [soUtil getUtf8StringFromNsData:nextPushData UpdateError:&error];
        if (nil != nextPushDataAsString && nil == error) {
            [jsonModel setNextPush:nextPushDataAsString];
        } else {
            [jsonModel setNextPush:ksoEmptyList];
        }
    } else {
        [jsonModel setNextPush:ksoEmptyList];
    }
    
    [mocp save:&error];
    if (nil != error) {
        [self persistentStoreProblem];
        return NO;
    }
    return YES;  // newly updated the persistent store
}

-(BOOL)loadMemoryFromDisk
{
    NSError *error = nil;
    NSError *error1 = nil;
    NSError *error2 = nil;
    NSError *error3 = nil;

    soModel *model = [soModel sharedInstance];
    NSManagedObjectContext* mocp = [self managedObjectContext];
    if (nil == mocp) {
        return NO;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JsonModel" inManagedObjectContext:mocp]; // Not NSLocalizedString
    [request setEntity:entity];
    NSMutableArray *mutableFetchResults = [[mocp executeFetchRequest:request error:&error] mutableCopy];
    if (nil != error) {
        [self persistentStoreProblem];
        return NO;
    }
    JsonModel *jsonModel;
    
    if ([mutableFetchResults count] == 0) {
        return YES; // There is no information on disk (first time use)
    } else {
        jsonModel = [mutableFetchResults objectAtIndex:0];
    }
    
    if (nil == [jsonModel lastFetch]) {
        [jsonModel setLastFetch:ksoEmptyList];
    }
    if (nil == [jsonModel nextPush]) {
        [jsonModel setNextPush:ksoEmptyList];
    }
  
    [model setAltogetherLastFetch:[soUtil ArrayFromJson:[jsonModel lastFetch] UpdateError:&error1]
                         NextPush:[soUtil ArrayFromJson:[jsonModel nextPush] UpdateError:&error2]];
    if (nil != error1 || nil != error2 || nil != error3) {
        [self jsonProblem];
        return NO;
    }
    
    return YES;
}

+ (void)processServerResponse:(NSURLResponse*)resp WithData:(NSData*)data WithError:(NSError*)error
{
    if (nil != error) {
        /*
         The reason for enumerating each error with a logged report is so that we can establish
         exactly what errors have been seen during development and testing, and what errors are
         unexpected from a development point of view, in case there are new types of failure mode
         we need to account for.
         */
        if ([error code] == -1004) {
            NSLog(@"Could not connect to the server (-1004)");
        } else if ([error code] == -1001) {
            NSLog(@"The request timed out (-1001)");
        } else {
            NSLog(@"Error connecting to server not seen before %d", [error code]);
        }
        return;
    }    
    NSError *errorConvertingToString = nil;
    NSString *fromServer = [soUtil getUtf8StringFromNsData:data UpdateError:&errorConvertingToString];

    if (errorConvertingToString != nil) {
        NSLog(@"We got a data conversion error from the server %@", [errorConvertingToString localizedDescription]);
        return;
    }
    if (nil == fromServer) {
        NSLog(@"We got nothing back from the server.");
        return;
    }
    NSLog(@"Server responded with %@", fromServer);
    
    NSError *errorConvertingServerResponse = nil;
    NSMutableArray *lastFetch = [soUtil ArrayFromJson:fromServer UpdateError:&errorConvertingServerResponse];
    if (nil != error) {
        NSLog(@"Could not decode server response, got error %@", [errorConvertingServerResponse localizedDescription]);
        return;
    }
    if (nil == lastFetch || [lastFetch count] <= 0) {
        NSLog(@"The server responded with an empty list of projects.  This can happen in a COLD START situation in the client.");
        return;
    }
    soModel *model = [soModel sharedInstance];
    [model setLastFetch:lastFetch];
    [[soDatabase sharedInstance]saveMemoryToDisk];    
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
    if (nil != error) {
        [self persistentStoreProblem];
        return NO;
    }
    
    NSString *jsonPacket;
    
    /*
     Do we have stored data for projects, or are we doing a COLD START?
     */
    if ([mutableFetchResults count] > 0) {
        JsonModel *jsonModel;
        jsonModel = [mutableFetchResults objectAtIndex:0];
        jsonPacket = [NSString stringWithFormat:
                      ksoDictTwoArray,
                      ksoLastFetch, [jsonModel lastFetch],
                      ksoNextPush, [jsonModel nextPush]
                      ];
    } else {
        jsonPacket = [NSString stringWithFormat:
                      ksoDictTwoArray,
                      ksoLastFetch, ksoEmptyList,
                      ksoNextPush, ksoEmptyList
                      ];
    }
    
    if (jsonPacket == nil) {
        return NO;
    }
    
    NSString *bodyData = [NSString stringWithFormat: @"Json=%@", [soUtil safeWebStringFromString:jsonPacket]];
  
    NSLog(@"Unencoded prepared for server:\n%@", jsonPacket);
    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[model serverUrlPrefix]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];

    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:[bodyData length]]];
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) =
    ^(NSURLResponse *resp, NSData *data, NSError *error) {
        [soDatabase processServerResponse:resp WithData:data WithError:error];
    };
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[self networkQueue] completionHandler:handler];

    return YES;
}

+ (BOOL)queuedUpdateDiskAndServerSimulatingFailure:(int)simulate_failure
{
    soDatabase *instance = [soDatabase sharedInstance];

    if (soDatabase_NoFailureSimulation != simulate_failure) {
        return NO;
    }
    if (![instance saveMemoryToDisk]) {
        return NO;
    }
    if (![instance syncWithServer]) {
        return NO;
    }
    return YES;
}

+ (BOOL)queuedUploadFromDiskAndServerSimulatingError:(int)simulate_failure
{
    soDatabase *instance = [soDatabase sharedInstance];
    
    if (soDatabase_NoFailureSimulation != simulate_failure) {
        return NO;
    }
    if (![instance loadMemoryFromDisk]) {
        return NO;
    }
    if (![instance syncWithServer]) {
        return NO;
    }
    return YES;
}

@end
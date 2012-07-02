//
//  soDatabase.m
//  SprintOverflow
//
//  Created by Faisal Memon on 17/05/2012.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "soDatabase.h"
//#import "acUtil.h"


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


+(void)fetchEpicData:(NSString *)forUser
{
    // Construct a Google Application Engine API request.
    // http://ios38722.appspot.com/barebones?Mode=Epic&User=JayRandomHacker
    //
    NSString *urlString = [NSString stringWithFormat:@"http://ios38722.appspot.com/barebones?Mode=Epic&User=%@", forUser];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Get the contents of the URL as a string, and parse the JSON into Foundation objects.
    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *results = [jsonString JSONValue];
    NSDictionary *epicDict = [results objectForKey:@"epic"];
    NSString *epicId = [epicDict objectForKey:@"epicId"];
    NSArray *stories = [epicDict  objectForKey:@"stories"];
    NSString *epicName = [epicDict objectForKey:@"epicName"];
    NSArray *keyArray = [epicDict allKeys];
    NSLog(@"The key array is %@", keyArray);
    //NSLog(@"EpicId is %@", epicId);
    
    /*
     Printing description of results:
     {
     epic =     {
     epicId = 872983;
     epicName = "Bootstrap the AgileOverflow project";
     stories =         (
     {
     storyId = 872984;
     storyName = "Create GAE default scenario response";
     tasks =                 (
     {
     status = NotStarted;
     taskId = 872985;
     taskName = "Create default scenario java class";
     }
     );
     }
     );
     };
     }
     */
    // Now we need to dig through the resulting objects.
    // Read the documentation and make liberal use of the debugger or logs.
    //return [[results objectForKey:@"user"] objectForKey:@"nsid"];
    return;

}
@end

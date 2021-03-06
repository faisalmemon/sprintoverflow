//
//  soAppDelegate.m
//  SprintOverflow
//
//  Created by Faisal Memon on 29/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "soAppDelegate.h"

#import "soWelcomeViewController.h"

#import "soSecondViewController.h"
#import "soDatabase.h"

@implementation soAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize uinavControllerWelcome;
@synthesize uinavControllerMilestone;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    /*
     There is a problem at initial launch, the application does not know what orientation it is in.
     Subsequent changes are tracked ok, however.  To solve this problem, we make the initial orientation
     the same as the status bar's orientation.
     */
    UIInterfaceOrientation startingOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    self->model = [soModel sharedInstance];
    [model bootstrap];
    
    self.uinavControllerWelcome = [[UINavigationController alloc]init];
    
    self.uinavControllerMilestone = [[UINavigationController alloc]init];

    soWelcomeViewController *welcomeViewController = [[soWelcomeViewController alloc] initWithNibName:@"welcome" bundle:nil]; // Not NSLocalizedString
    [welcomeViewController setOrientation:startingOrientation];
    
    UIViewController *viewController2 = [[soSecondViewController alloc] initWithNibName:@"soSecondViewController" bundle:nil]; // Not NSLocalizedString
    
    [uinavControllerWelcome pushViewController:welcomeViewController animated:NO];
    [uinavControllerMilestone pushViewController:viewController2 animated:NO];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:uinavControllerWelcome, uinavControllerMilestone, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end

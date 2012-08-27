//
//  soAppDelegate.h
//  SprintOverflow
//
//  Created by Faisal Memon on 29/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON/JSON.h"

@interface soAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {

}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *uinavControllerWelcome;
@property (strong, nonatomic) UINavigationController *uinavControllerMilestone;

@end

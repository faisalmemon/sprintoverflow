//
//  soWelcomeViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 29/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface soWelcomeViewController : UIViewController {
    UIInterfaceOrientation _orientation;
}

@property (nonatomic) UIInterfaceOrientation orientation;

- (IBAction)drillIntoJoin:(UIButton*)sender;
- (IBAction)drillIntoStartProject:(id)sender;
- (IBAction)drillIntoCurrentProjects:(id)sender;

@end

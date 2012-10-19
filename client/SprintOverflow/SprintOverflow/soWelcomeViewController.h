//
//  soWelcomeViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 29/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "soScreenJumpProtocol.h"

enum soJumpState {
    soNoJump,
    soJumpToProject
};

@interface soWelcomeViewController : UIViewController <soScreenJumpProtocol> {
    UIInterfaceOrientation _orientation;
    enum soJumpState _jumpState;
    NSString *_toProject;
    NSString *_withSecurityToken;
}

@property (nonatomic) UIInterfaceOrientation orientation;

- (IBAction)drillIntoJoin:(UIButton*)sender;
- (IBAction)drillIntoStartProject:(id)sender;
- (IBAction)drillIntoCurrentProjects:(id)sender;

@end

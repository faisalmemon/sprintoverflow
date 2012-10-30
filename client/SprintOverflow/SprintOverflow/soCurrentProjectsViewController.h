//
//  soCurrentProjectsViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 02/10/2012.
//
//

#import <UIKit/UIKit.h>
#import "soModel.h"
#import "soCurrentProject.h"

@interface soCurrentProjectsViewController : UITableViewController {
    UIInterfaceOrientation _orientation;
    soModel* _model;
    NSMutableArray* _currentProjects;
}

@property (nonatomic) UIInterfaceOrientation orientation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithProjectOwnerEmail:(NSString*)project_owner_email WithSecurityToken:(NSString*)security_token;

@end

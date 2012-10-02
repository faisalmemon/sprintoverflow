//
//  soWelcomeViewController.m
//  SprintOverflow
//
//  Created by Faisal Memon on 29/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "soWelcomeViewController.h"
#import "soJoinViewController.h"
#import "soCreateViewController.h"
#import "soCurrentProjectsViewController.h"

@interface soWelcomeViewController ()

@end

@implementation soWelcomeViewController

@synthesize orientation = _orientation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Projects", @"Projects welcome screen");
        self.tabBarItem.image = [UIImage imageNamed:@"first"]; // Not NSLocalizedString
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    _orientation = toInterfaceOrientation;
}


-(IBAction) drillIntoJoin:(UIButton*)sender
{
    soJoinViewController *joinvc;
    joinvc = [[soJoinViewController alloc] initWithNibName:@"join" bundle:nil]; // Not NSLocalizedString
    
    joinvc.title = NSLocalizedString(@"Join", @"Screen where you Join a project; join here means to participate in the project");
    joinvc.orientation = _orientation;
    [self.navigationController pushViewController: joinvc animated:YES];
}

- (IBAction)drillIntoCurrentProjects:(id)sender
{
    soCurrentProjectsViewController *currentprojvc;
    currentprojvc = [[soCurrentProjectsViewController alloc] initWithNibName:@"soCurrentProjectsViewController" bundle:nil]; // Not NSLocalizedString
    
    currentprojvc.title = NSLocalizedString(@"Current Projects", @"Screen where you look at the projects you are currently using");
    [currentprojvc setOrientation:[self orientation]];
    [self.navigationController pushViewController:currentprojvc animated:YES];
}

- (IBAction)drillIntoStartProject:(id)sender {
    soCreateViewController *createvc;
    createvc = [[soCreateViewController alloc] initWithNibName:@"soCreateViewController" bundle:nil] ; // Not NSLocalizedString
    createvc.title = NSLocalizedString(@"Create", @"Screen where you Create a project");
    createvc.orientation = _orientation;
    [self.navigationController pushViewController: createvc animated:YES];
}

@end

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

@interface soWelcomeViewController ()

@end

@implementation soWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Projects", @"Projects welcome screen");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return TRUE;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    orientation = toInterfaceOrientation;
}


-(IBAction) drillIntoJoin:(UIButton*)sender
{
    soJoinViewController *joinvc;
    joinvc = [[soJoinViewController alloc] initWithNibName:@"join" bundle:nil] ;
    
    joinvc.title = @"Join";
    joinvc.orientation = orientation;
    [self.navigationController pushViewController: joinvc animated:YES];
}

- (IBAction)drillIntoStartProject:(id)sender {
    soCreateViewController *createvc;
    createvc = [[soCreateViewController alloc] initWithNibName:@"soCreateViewController" bundle:nil] ;
    
    createvc.title = @"Create";
    createvc.orientation = orientation;
    [self.navigationController pushViewController: createvc animated:YES];
}

@end

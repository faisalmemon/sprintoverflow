//
//  soWelcomeViewController.m
//  SprintOverflow
//
//  Created by Faisal Memon on 29/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "soWelcomeViewController.h"
#import "soJoinViewController.h"

@interface soWelcomeViewController ()

@end

@implementation soWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
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

-(IBAction) drillIntoJoin:(UIButton*)sender
{
    soJoinViewController *joinvc;
    joinvc = [[soJoinViewController alloc] initWithNibName:@"join" bundle:nil] ;
    
    joinvc.title = @"Join an Existing Project";
    [self.navigationController pushViewController: joinvc animated:NO];
}

@end

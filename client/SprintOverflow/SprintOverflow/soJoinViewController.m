//
//  soJoinViewController.m
//  SprintOverflow
//
//  Created by Faisal Memon on 31/07/2012.
//
//

#import "soJoinViewController.h"

// Create a local method to intialize the view controller
@interface soJoinViewController ()
- (void)viewControllerInit;
@end


@implementation soJoinViewController

@synthesize handleScrollView;
@synthesize projectIdText;
@synthesize projectOwnerEmailText;
@synthesize handleSearchBar;

- (void)viewControllerInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self viewControllerInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setProjectIdText:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setHandleScrollView:nil];
    [self setHandleSearchBar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return TRUE;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.projectIdText == textField) {
        NSLog(@"project Id field should return");
        [textField resignFirstResponder];
    } else if (self.projectOwnerEmailText == textField) {
        NSLog(@"project owner text field should return");
        [projectOwnerEmailText resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentlyEditing = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentlyEditing = nil;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (handleSearchBar == searchBar) {
        currentlyEditing = searchBar;
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    return YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    currentlyEditing = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    lastSearchText = searchBar.text;
    [searchBar endEditing:YES];
}

- (CGPoint)originOfControl:(NSObject*)control
{
    CGPoint point = CGPointMake(0,0);
    
    if ([control isKindOfClass:[UITextField class]]) {
        UITextField* textField = (UITextField*)control;
        point = textField.frame.origin;
        return point;
    } else if ([control isKindOfClass:[UISearchBar class]]) {
        UISearchBar* searchBar = (UISearchBar*)control;
        point = searchBar.frame.origin;
        return point;
    } else {
        NSLog(@"Unknown current control type to find origin of");
        return point;
    }
}

#pragma mark - Notification Handlers

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    handleScrollView.contentInset = contentInsets;
    handleScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    CGPoint originOfCurrentControl = [self originOfControl:currentlyEditing];
    if (!CGRectContainsPoint(aRect, originOfCurrentControl) ) {
        CGPoint scrollPoint = CGPointMake(originOfCurrentControl.x, originOfCurrentControl.y - kbSize.height);
        [handleScrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    handleScrollView.contentInset = contentInsets;
    handleScrollView.scrollIndicatorInsets = contentInsets;
}

@end
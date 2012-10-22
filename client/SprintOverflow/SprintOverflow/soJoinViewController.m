//
//  soJoinViewController.m
//  SprintOverflow
//
//  Created by Faisal Memon on 31/07/2012.
//
//

#import "soJoinViewController.h"
#import "soUtil.h"
#import "soConstants.h"
#import "soModel.h"

// Create a local method to intialize the view controller
@interface soJoinViewController ()
- (void)viewControllerInit;
@end


@implementation soJoinViewController
@synthesize orientation=_orientation;
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
    ownerEmailAddressTextFieldOriginalColor = [projectOwnerEmailText backgroundColor];
    
}

- (void)viewDidUnload
{
    [self setProjectIdText:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setHandleScrollView:nil];
    [self setHandleSearchBar:nil];
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [self setOrientation:toInterfaceOrientation];
}

- (void)kickStateMachine
{
    if (projectIdText.text != nil && projectOwnerEmailText != nil &&
        [soUtil isValidEmail:projectOwnerEmailText.text Strictly:YES]) {
        [[soModel sharedInstance] joinProjectOwnerEmail:projectOwnerEmailText.text WithIdOrToken:projectIdText.text];
        [[[soModel sharedInstance] delegateScreenJump] nextScreenShouldShowProjectWithOwner:projectOwnerEmailText.text WithSecurityToken:projectIdText.text];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentlyEditing = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentlyEditing = nil;
    if (projectOwnerEmailText == textField) {
        if ([soUtil isValidEmail:textField.text Strictly:YES]) {
            [projectOwnerEmailText setBackgroundColor:ownerEmailAddressTextFieldOriginalColor];
        } else {
            [projectOwnerEmailText setBackgroundColor:[soConstants faultyEmailAddressBackgroundColor]];
        }
    }
    [self kickStateMachine];
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

- (CGRect)originOfControl:(NSObject*)control
{
    CGRect rect = CGRectMake(0, 0, 0, 0);
    
    if ([control isKindOfClass:[UITextField class]]) {
        UITextField* textField = (UITextField*)control;
        rect = textField.frame;
    } else if ([control isKindOfClass:[UISearchBar class]]) {
        UISearchBar* searchBar = (UISearchBar*)control;
        rect = searchBar.frame;
    } else {
        NSLog(@"Unknown current control type to find origin of");
    }
    return rect;
}

#pragma mark - Notification Handlers

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    /*
     Find the keyboard extent, mapping to the co-ordinate space of the scroll view.
     The origin of this is the bottom left of the keyboard.  Note, convertToRect also
     rotates the co-ords to be in the scroll view orientation.
     */
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardRect = [handleScrollView convertRect:keyboardRect fromView:nil];
    CGPoint keyboardTopLeft = { 0, keyboardRect.origin.y - keyboardRect.size.height};

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.size.height, 0.0);
    handleScrollView.contentInset = contentInsets;
    handleScrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect originOfCurrentControl = [self originOfControl:currentlyEditing];
    CGPoint controlBottomLeft = {
        originOfCurrentControl.origin.x,
        originOfCurrentControl.origin.y + originOfCurrentControl.size.height
    };
    CGPoint scrollPoint = {
        0,
        MAX(0, controlBottomLeft.y - keyboardTopLeft.y)
    };
    savedContentOffset = [handleScrollView contentOffset];
    [handleScrollView setContentOffset:scrollPoint animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    handleScrollView.contentInset = contentInsets;
    handleScrollView.scrollIndicatorInsets = contentInsets;
    [handleScrollView setContentOffset:savedContentOffset animated:YES];
}

@end
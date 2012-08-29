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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    orientation = toInterfaceOrientation;
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

- (CGPoint)getScrollPointForControlAt:(CGPoint)bottomLeft WithKeyboard:(CGSize)keyboard
{
    NSLog(@"getScrollPointForControlAt %f %f with keyboard %f %f", bottomLeft.x,
          bottomLeft.y, keyboard.width, keyboard.height);
    CGPoint returnPoint = { 0, 0};
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        if (bottomLeft.y >= 133) {
            returnPoint.y = bottomLeft.y - 133 + 20;
        }
    } else {
        if (bottomLeft.y < 200) {
            // do nothing
        } else if (bottomLeft.y >= 200) {
            returnPoint.y = bottomLeft.y - 200 + 20;
        }
    }
    return returnPoint;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardRect = [handleScrollView convertRect:keyboardRect fromView:nil];

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.size.height, 0.0);
    handleScrollView.contentInset = contentInsets;
    handleScrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect originOfCurrentControl = [self originOfControl:currentlyEditing];
    CGPoint bottomLeft = originOfCurrentControl.origin;
    bottomLeft.y += originOfCurrentControl.size.height;
    CGPoint scrollPoint;
    savedContentOffset = [handleScrollView contentOffset];
    scrollPoint.x = 0;
    scrollPoint.y = MAX(0, bottomLeft.y - (keyboardRect.origin.y - keyboardRect.size.height));
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
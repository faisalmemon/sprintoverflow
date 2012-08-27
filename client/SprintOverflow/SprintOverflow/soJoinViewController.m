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

-(CGPoint)screenCoordsFromLocalPoint:(CGPoint)localPosition
{
    return [handleScrollView convertPoint:localPosition toView:nil];
}

-(CGRect)screenCoordsFromLocalRect:(CGRect)localRect
{
    CGRect returnRect = localRect;
    CGPoint adjustedPoint = [self screenCoordsFromLocalPoint:localRect.origin];
    returnRect.origin = adjustedPoint;
    return returnRect;
}

- (CGRect)originOfControlInScreenCoords:(NSObject*)control
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
    rect.origin = [self screenCoordsFromLocalPoint:rect.origin];
    return rect;
}

#pragma mark - Notification Handlers

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    /*
     When the keyboard shows, the tab bar is lost, thus making the scrollable area taller,
     and the keyboard slides in, thus obscuring some of the scrollable area underneath.
     We need to correct for both.  We also need to work in screen coords because the top of
     the screen with show the carrier signal bar, and the navigation bar titles, and the
     keyboard sizes come in screen coords.
     */
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        CGSize rotatedSize;
        rotatedSize.height = kbSize.width;
        rotatedSize.width = kbSize.height;
        kbSize = rotatedSize;
    }
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    handleScrollView.contentInset = contentInsets;
    handleScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect = [self screenCoordsFromLocalRect:aRect];
    aRect.size.height -= kbSize.height;
    
    CGRect originOfCurrentControl = [self originOfControlInScreenCoords:currentlyEditing];
    CGPoint bottomLeft = originOfCurrentControl.origin;
    bottomLeft.y += originOfCurrentControl.size.height;
    if (!CGRectContainsPoint(aRect, bottomLeft)) {
        CGPoint scrollPoint = CGPointMake(0, bottomLeft.y - kbSize.height - tabBarHeight) ;
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
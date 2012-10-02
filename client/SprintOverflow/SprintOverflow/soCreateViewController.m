//
//  soCreateViewController.m
//  SprintOverflow
//
//  Created by Faisal Memon on 29/08/2012.
//
//

#import "soCreateViewController.h"
#import "soEpicViewController.h"

#import "soConstants.h"
#import "soUtil.h"

@interface soCreateViewController ()

@end

@implementation soCreateViewController
@synthesize handleProjectId;
@synthesize handleOwnerEmailAddress;
@synthesize handleScrollView;
@synthesize handleSecurityTokenExplanation;
@synthesize handleSecurityToken;
@synthesize handleCreateProjectButton;
@synthesize orientation;

- (void)viewControllerInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    model = [soModel sharedInstance];
    state = soInitialState;
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
    handleScrollView.contentSize=CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
    ownerEmailAddressTextFieldOriginalColor = handleOwnerEmailAddress.backgroundColor;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setHandleProjectId:nil];
    [self setHandleScrollView:nil];
    [self setHandleOwnerEmailAddress:nil];
    [self setHandleSecurityTokenExplanation:nil];
    [self setHandleSecurityToken:nil];
    [self setHandleCreateProjectButton:nil];
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

- (void)updateStateMachine:(enum soCreateActions)action
{
    if (action == soModifyingText) {
        if (state == soShowSecurityToken) {
            handleSecurityTokenExplanation.hidden=YES;
            handleSecurityToken.text = nil;
            handleSecurityToken.hidden=YES;
            handleCreateProjectButton.hidden=YES;
            state = soHideSecurityToken;
            [handleScrollView layoutIfNeeded];
            return;
        }
    }
    if (action == soNotModifyingText) {
        if (0 != handleProjectId.text.length && 0 != handleOwnerEmailAddress.text.length &&
            [soUtil isValidEmail:handleOwnerEmailAddress.text Strictly:YES]) {
            handleSecurityToken.text = [model securityCodeFromId:handleProjectId.text FromOwner:handleOwnerEmailAddress.text];
        }
        if (state == soHideSecurityToken && [handleSecurityToken.text length] > 0) {
            handleSecurityTokenExplanation.hidden=NO;
            handleSecurityToken.hidden=NO;
            handleCreateProjectButton.hidden=NO;
            [handleScrollView layoutIfNeeded];
            state = soShowSecurityToken;
        }
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
    [self updateStateMachine:soModifyingText];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentlyEditing = nil;
    if (handleOwnerEmailAddress == textField) {
        if ([soUtil isValidEmail:textField.text Strictly:YES]) {
            [handleOwnerEmailAddress setBackgroundColor:ownerEmailAddressTextFieldOriginalColor];
        } else {
            [handleOwnerEmailAddress setBackgroundColor:[soConstants faultyEmailAddressBackgroundColor]];
        }
    }
    
    [self updateStateMachine:soNotModifyingText];
}

- (CGRect)originOfControl:(NSObject*)control
{
    CGRect rect = CGRectMake(0, 0, 0, 0);
    
    if ([control isKindOfClass:[UITextField class]]) {
        UITextField* textField = (UITextField*)control;
        rect = textField.frame;
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

- (IBAction)clickedCreateButton:(id)sender {
    NSString *project_id = [NSString stringWithString:handleProjectId.text];
    NSString *owner_email = [NSString stringWithString:handleOwnerEmailAddress.text];
    NSString *security_code = [NSString stringWithString:handleSecurityToken.text];

    [[soModel sharedInstance] addProjectOwnerEmail:owner_email WithID:project_id WithSecurityToken:security_code ];
    
    soEpicViewController *epicvc;
    NSString *epicViewTitle = [[NSString alloc] initWithFormat:@"%@ %@", project_id, NSLocalizedString(@"Epics", @"Screen where you manage the Epic task level for a  project")];
    epicvc = [[ soEpicViewController alloc] initWithNibName:@"soEpicViewController" bundle:nil];
    epicvc.title = epicViewTitle;
    epicvc.orientation = orientation;
    //[self.navigationController popToRootViewControllerAnimated:YES];
    // CONTINUE HERE
    // change code to use a protocol to get the root view controller to show and then to drill
    // down to get to the new project.
    [self.navigationController pushViewController:epicvc animated:YES];
}

@end
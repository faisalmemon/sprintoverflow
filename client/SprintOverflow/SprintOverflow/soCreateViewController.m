//
//  soCreateViewController.m
//  SprintOverflow
//
//  Created by Faisal Memon on 29/08/2012.
//
//
#import <MessageUI/MessageUI.h>

#import "soCreateViewController.h"
#import "soEpicViewController.h"
#import "soCurrentProjectsViewController.h"

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
@synthesize handleSecurityButton;
@synthesize handleSecurityExplanation;
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

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Hello from California!"];
	
    
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
	// Fill out the email body text
	NSString *emailBody = @"It is raining in sunny California!";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
}

-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
	NSString *body = @"&body=It is raining in sunny California!";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void) emailProjectOwner:(NSString*)project_owner_email WithId:(NSString*)project_id WithSecurityToken:(NSString*)security_token
{
    // CONTINUE HERE by passing the strings down to the helper functions
    // add member data to remember this info so that the delegate can switch to the
    // currentvc after the email
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}

}

- (IBAction)clickedCreateButton:(id)sender {
    NSString *project_id = [NSString stringWithString:handleProjectId.text];
    NSString *owner_email = [NSString stringWithString:handleOwnerEmailAddress.text];
    NSString *security_code = [NSString stringWithString:handleSecurityToken.text];

    [model addProjectOwnerEmail:owner_email WithID:project_id WithSecurityToken:security_code WithDiscovery:lockButtonState == soLockButtonLocked ? ksoNO : ksoYES];
    
    [self emailProjectOwner:owner_email WithId:project_id WithSecurityToken:security_code];

    soCurrentProjectsViewController* currentvc = [[soCurrentProjectsViewController alloc] initWithNibName:@"soCurrentProjectsViewController" bundle:nil WithProjectOwnerEmail:owner_email WithSecurityToken:security_code];
    
    // CONTINUE HERE fix this so that in the mail composer delegate, it switches to the currentvc
    // having it here means you get a transition followed immediately by the modal mail composer tool
    [self.navigationController pushViewController:currentvc animated:YES];
}

- (IBAction)clickedSecurityButton:(id)sender {
    [handleOwnerEmailAddress resignFirstResponder];
    [handleProjectId resignFirstResponder];
    
    if (lockButtonState == soLockButtonLocked) {
        lockButtonState = soLockButtonUnlocked;
        [handleSecurityButton setImage:[UIImage imageNamed:ksoUnlockedImage]  forState:UIControlStateNormal];
        handleSecurityExplanation.text = NSLocalizedString(@"This project can be joined using the Project ID or Security Token", @"Next to a padlock lock symbol, for when a security feature is switched off");

    } else {
        lockButtonState = soLockButtonLocked;
        [handleSecurityButton setImage:[UIImage imageNamed:ksoLockedImage]  forState:UIControlStateNormal];
        handleSecurityExplanation.text = NSLocalizedString(@"The security token is needed for people to join this project", @"Next to a padlock lock symbol, for when a security feature is switched on");
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSLog (@"After attempting an email, result was %d", result);
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

@end
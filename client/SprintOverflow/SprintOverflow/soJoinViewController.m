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

@synthesize projectIdText;
@synthesize projectOwnerEmailText;

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
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return TRUE;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.projectIdText resignFirstResponder];
    return YES;
}

#pragma mark - Notification Handlers

- (void)keyboardWillShow:(NSNotification *)notification
{
    // I'll try to make my text field 20 pixels above the top of the keyboard
    // To do this first we need to find out where the keyboard will be.
    
    NSValue *keyboardEndFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [keyboardEndFrameValue CGRectValue];
    
    // When we move the textField up, we want to match the animation duration and curve that
    // the keyboard displays. So we get those values out now
    
    NSNumber *animationDurationNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationNumber doubleValue];
    
    NSNumber *animationCurveNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = [animationCurveNumber intValue];
    
    // UIView's block-based animation methods anticipate not a UIVieAnimationCurve but a UIViewAnimationOptions.
    // We shift it according to the docs to get this curve.
    
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    
    // Now we set up our animation block.
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         // Now we just animate the text field up an amount according to the keyboard's height,
                         // as we mentioned above.
                         CGRect textFieldFrame = self.projectIdText.frame;
                         textFieldFrame.origin.y = keyboardEndFrame.origin.y - textFieldFrame.size.height - 40; //I don't think the keyboard takes into account the status bar
                         self.projectIdText.frame = textFieldFrame;
                     }
                     completion:^(BOOL finished) {}];
    
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    
    NSNumber *animationDurationNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationNumber doubleValue];
    
    NSNumber *animationCurveNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = [animationCurveNumber intValue];
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         self.projectIdText.frame = CGRectMake(20, 409, 280, 31); //just some hard coded value
                     }
                     completion:^(BOOL finished) {}];
    
}

@end

/*
 @interface ViewController ()
 
 - (void)viewControllerInit;
 
 @end
 
 @implementation ViewController
 
 @synthesize textField;
 
 - (id)initWithCoder:(NSCoder *)coder {
 self = [super initWithCoder:coder];
 if (self) {
 [self viewControllerInit];
 }
 return self;
 }
 
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
 {
 [self viewControllerInit];
 }
 return self;
 }
 
 
 - (void)viewControllerInit
 {
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
 }
 
 
 - (void)dealloc {
 [[NSNotificationCenter defaultCenter] removeObserver:self];
 }
 
 
 #pragma mark - Notification Handlers
 
 - (void)keyboardWillShow:(NSNotification *)notification
 {
 // I'll try to make my text field 20 pixels above the top of the keyboard
 // To do this first we need to find out where the keyboard will be.
 
 NSValue *keyboardEndFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
 CGRect keyboardEndFrame = [keyboardEndFrameValue CGRectValue];
 
 // When we move the textField up, we want to match the animation duration and curve that
 // the keyboard displays. So we get those values out now
 
 NSNumber *animationDurationNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
 NSTimeInterval animationDuration = [animationDurationNumber doubleValue];
 
 NSNumber *animationCurveNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
 UIViewAnimationCurve animationCurve = [animationCurveNumber intValue];
 
 // UIView's block-based animation methods anticipate not a UIVieAnimationCurve but a UIViewAnimationOptions.
 // We shift it according to the docs to get this curve.
 
 UIViewAnimationOptions animationOptions = animationCurve << 16;
 
 
 // Now we set up our animation block.
 [UIView animateWithDuration:animationDuration
 delay:0.0
 options:animationOptions
 animations:^{
 // Now we just animate the text field up an amount according to the keyboard's height,
 // as we mentioned above.
 CGRect textFieldFrame = self.textField.frame;
 textFieldFrame.origin.y = keyboardEndFrame.origin.y - textFieldFrame.size.height - 40; //I don't think the keyboard takes into account the status bar
 self.textField.frame = textFieldFrame;
 }
 completion:^(BOOL finished) {}];
 
 }
 
 
 - (void)keyboardWillHide:(NSNotification *)notification
 {
 
 NSNumber *animationDurationNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
 NSTimeInterval animationDuration = [animationDurationNumber doubleValue];
 
 NSNumber *animationCurveNumber = [[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
 UIViewAnimationCurve animationCurve = [animationCurveNumber intValue];
 UIViewAnimationOptions animationOptions = animationCurve << 16;
 
 [UIView animateWithDuration:animationDuration
 delay:0.0
 options:animationOptions
 animations:^{
 self.textField.frame = CGRectMake(20, 409, 280, 31); //just some hard coded value
 }
 completion:^(BOOL finished) {}];
 
 }
 #pragma mark - View lifecycle
 
 - (void)viewDidUnload
 {
 [self setTextField:nil];
 [super viewDidUnload];
 // Release any retained subviews of the main view.
 // e.g. self.myOutlet = nil;
 }
 
 #pragma mark - UITextFieldDelegate
 
 - (BOOL)textFieldShouldReturn:(UITextField *)textField
 {
 [self.textField resignFirstResponder];
 return YES;
 }
 
 @end
 share|improve this answer
 */

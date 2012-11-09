//
//  soCreateViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 29/08/2012.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "soModel.h"

enum soCreateStateMachine {
    soInitialState = 0,
    soHideSecurityToken = soInitialState,
    soShowSecurityToken
};

enum soLockButtonStatus {
    soInitialLockButtonState = 0,
    soLockButtonLocked = soInitialLockButtonState,
    soLockButtonUnlocked
};

enum soCreateActions {
    soModifyingText,
    soNotModifyingText,
};

@interface soCreateViewController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate> {
    UIInterfaceOrientation orientation;
    NSObject* currentlyEditing;
    CGPoint savedContentOffset;
    UIColor *ownerEmailAddressTextFieldOriginalColor;
    soModel* model;
    enum soCreateStateMachine state;
    enum soLockButtonStatus lockButtonState;
}

@property (weak, nonatomic) IBOutlet UITextField *handleProjectId;
@property (weak, nonatomic) IBOutlet UITextField *handleOwnerEmailAddress;
@property (weak, nonatomic) IBOutlet UIScrollView *handleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *handleSecurityTokenExplanation;
@property (weak, nonatomic) IBOutlet UILabel *handleSecurityToken;
@property (weak, nonatomic) IBOutlet UIButton *handleCreateProjectButton;
@property (weak, nonatomic) IBOutlet UIButton *handleSecurityButton;
@property (weak, nonatomic) IBOutlet UILabel *handleSecurityExplanation;

@property (nonatomic) UIInterfaceOrientation orientation;

- (IBAction)clickedCreateButton:(id)sender;

- (IBAction)clickedSecurityButton:(id)sender;


@end

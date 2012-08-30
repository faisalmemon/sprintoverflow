//
//  soCreateViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 29/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "soModel.h"

enum soCreateStateMachine {
    soInitialState = 0,
    soHideSecurityToken = soInitialState,
    soShowSecurityToken
};

enum soCreateActions {
    soModifyingText,
    soNotModifyingText,
};

@interface soCreateViewController : UIViewController <UITextFieldDelegate> {
    UIInterfaceOrientation orientation;
    NSObject* currentlyEditing;
    CGPoint savedContentOffset;
    soModel* model;
    enum soCreateStateMachine state;
}

@property (weak, nonatomic) IBOutlet UITextField *handleProjectId;
@property (weak, nonatomic) IBOutlet UITextField *handleOwnerEmailAddress;
@property (weak, nonatomic) IBOutlet UIScrollView *handleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *handleSecurityTokenExplanation;
@property (weak, nonatomic) IBOutlet UILabel *handleSecurityToken;
@property (weak, nonatomic) IBOutlet UIButton *handleCreateProjectButton;
@property (nonatomic) UIInterfaceOrientation orientation;

@end

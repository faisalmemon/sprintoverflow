//
//  soCreateViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 29/08/2012.
//
//

#import <UIKit/UIKit.h>

@interface soCreateViewController : UIViewController <UITextFieldDelegate> {
    UIInterfaceOrientation orientation;
    NSObject* currentlyEditing;
    CGPoint savedContentOffset;
}

@property (weak, nonatomic) IBOutlet UITextField *handleProjectName;
@property (weak, nonatomic) IBOutlet UITextField *handleOwnerEmailAddress;
@property (weak, nonatomic) IBOutlet UIScrollView *handleScrollView;
@property (nonatomic) UIInterfaceOrientation orientation;

@end

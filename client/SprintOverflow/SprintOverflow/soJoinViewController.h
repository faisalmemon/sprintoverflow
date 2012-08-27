//
//  soJoinViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 31/07/2012.
//
//

#import <UIKit/UIKit.h>

@interface soJoinViewController : UIViewController <UITextFieldDelegate> {
    CGRect savedFramePositionBeforeAnimation;
}
@property (nonatomic, retain) IBOutlet UITextField *projectIdText;
@property (nonatomic, retain) IBOutlet UITextField *projectOwnerEmailText;


@end

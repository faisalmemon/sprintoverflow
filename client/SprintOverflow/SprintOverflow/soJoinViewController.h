//
//  soJoinViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 31/07/2012.
//
//

#import <UIKit/UIKit.h>

@interface soJoinViewController : UIViewController <UITextFieldDelegate, UISearchBarDelegate> {
    CGRect savedFramePositionBeforeAnimation;
    NSObject* currentlyEditing;
    NSString* lastSearchText;
}
@property (weak, nonatomic) IBOutlet UIScrollView *handleScrollView;
@property (nonatomic, retain) IBOutlet UITextField *projectIdText;
@property (nonatomic, retain) IBOutlet UITextField *projectOwnerEmailText;
@property (weak, nonatomic) IBOutlet UISearchBar *handleSearchBar;


@end

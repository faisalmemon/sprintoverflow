//
//  soJoinViewController.h
//  SprintOverflow
//
//  Created by Faisal Memon on 31/07/2012.
//
//

#import <UIKit/UIKit.h>

@interface soJoinViewController : UIViewController <UITextFieldDelegate, UISearchBarDelegate> {
    NSObject* currentlyEditing;
    NSString* lastSearchText;
    UIColor* ownerEmailAddressTextFieldOriginalColor;
    UIInterfaceOrientation _orientation;
    CGPoint savedContentOffset;
}
@property (weak, nonatomic) IBOutlet UIScrollView *handleScrollView;
@property (nonatomic, retain) IBOutlet UITextField *projectIdText;
@property (nonatomic, retain) IBOutlet UITextField *projectOwnerEmailText;
@property (weak, nonatomic) IBOutlet UISearchBar *handleSearchBar;
@property (nonatomic) UIInterfaceOrientation orientation;
@end

//
//  soCurrentProjects.h
//  SprintOverflow
//
//  Created by Faisal Memon on 30/10/2012.
//
//

#import <Foundation/Foundation.h>

enum soVisualHint {
    soSelectableProject,
    soDiscoveryInProgress,
    soDiscoveryFailed,
};

@interface soCurrentProject : NSObject {
    NSString* _label;
    NSString* _detailLabel;
    enum soVisualHint _hint;
}

@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSString* detailLabel;
@property (nonatomic) enum soVisualHint hint;


@end

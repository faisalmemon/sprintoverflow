//
//  soScreenJumpProtocol.h
//  SprintOverflow
//
//  Created by Faisal Memon on 16/10/2012.
//
//

#import <Foundation/Foundation.h>

/*
 Screen Jump Protocol
 
 The goal of the Screen Jump Protcol is to make it easier to use the application without
 excessive navigation around the different screens.  Instead, the application automatically
 moves between screens, using animation, whenever the context suits a change of screen.
 For example, when you elect to join an existing project, having input the credentials to
 join, you should be taken to the screen showing the project.  If this was a navigation
 controller push then later on when you exit the screen, you'd get to the join screen.  This
 feels wrong.  Instead, the application will take you from the initial join screen to the
 root screen, then automatically go to the current projects screen, select the newly joined
 project and then drill into that project.  Thus the user has a sensible back option, to go
 to the current projects screen.  The user also sees how the different screens relate to
 each other, in contrast to merely being teleported to the project screen.
 
 The jump protocol fits into the application by being a setable delegate on the model.
 One view controller implements the screen jump protocol, the root controller
 (welcomeViewController) and messages the model to set itself as the screen jump delegate.
 
 */
@protocol soScreenJumpProtocol
@required

- (void)nextScreenShouldShowProjectWithOwner:(NSString*)projectOwnerEmail WithSecurityToken:(NSString*)securityToken;
@end

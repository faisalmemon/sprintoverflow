//
//  soModelUpdateProtocol.h
//  SprintOverflow
//
//  Created by Faisal Memon on 09/11/2012.
//
//

#import <Foundation/Foundation.h>

/*
 The soModelUpdateProtocol allows a view controller to respond to asynchronously updated
 model information.  It will typically reload its snapshot data from the model.
 */

@protocol soModelUpdateProtocol <NSObject>
@required

/*
 The implementer must respond to the model being updated.  Invalidating its local data and reloading
 from the model are typical actions.
 
 Thread safety: This message is guaranteed to be dispatched onto the main thread.
 */
- (void) modelUpdated;

@end
//
//  ProjectList.h
//  SprintOverflow
//
//  Created by Faisal Memon on 13/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProjectList : NSManagedObject

@property (nonatomic, retain) NSString * projectOwnerEmail;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) NSString * securityToken;

@end

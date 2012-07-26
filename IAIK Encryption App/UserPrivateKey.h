//
//  UserPrivateKey.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 26.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserIdentity;

@interface UserPrivateKey : NSManagedObject

@property (nonatomic, retain) NSString * accessKey;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) UserIdentity *ref_identity;

@end

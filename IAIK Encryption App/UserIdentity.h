//
//  UserIdentity.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 26.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserCertificate;

@interface UserIdentity : NSManagedObject

@property (nonatomic, retain) NSManagedObject *ref_private_key;
@property (nonatomic, retain) UserCertificate *ref_certificate;

@end

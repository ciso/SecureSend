//
//  Recipient.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/ABAddressBook.h>

@interface Recipient : NSObject

@property (nonatomic, assign) ABRecordRef recordRef;
@property (nonatomic, strong) NSDate *expirationDate;

@end

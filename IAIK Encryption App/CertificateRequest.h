//
//  CertificateRequest.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 10.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CertificateRequest : NSObject {
    NSDate *date;
    NSString *emailAddress;
}

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *emailAddress;

- (NSString*) toXML;

@end

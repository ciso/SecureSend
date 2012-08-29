//
//  Email.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Email : NSObject

@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;

@end

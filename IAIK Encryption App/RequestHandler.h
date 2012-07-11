//
//  RequestHandler.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestHandler : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSData* request;
@property (nonatomic, strong) id delegate;

- (void)requestReceived;

@end

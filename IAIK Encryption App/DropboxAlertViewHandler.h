//
//  DropboxAlertViewHandler.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropboxAlertViewHandler : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) id delegate;

@end

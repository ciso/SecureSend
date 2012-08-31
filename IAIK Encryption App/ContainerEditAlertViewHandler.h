//
//  ContainerEditAlertViewHandler.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 31.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContainerEditAlertViewHandler : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIViewController *caller;
@property (nonatomic, strong) UITableViewCell *cell;

@end

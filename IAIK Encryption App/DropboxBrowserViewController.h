//
//  DropboxBrowserViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@class SecureContainer;

@interface DropboxBrowserViewController : UITableViewController <DBRestClientDelegate>

@property (nonatomic, strong) RootViewController *root;
@property (nonatomic, strong) NSString *dropboxPath;
@property (nonatomic, strong) SecureContainer *container;
@property (nonatomic, strong) id caller;

@end

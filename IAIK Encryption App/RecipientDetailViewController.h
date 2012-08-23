//
//  RecipientDetailViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Recipient;

@interface RecipientDetailViewController : UITableViewController

@property (nonatomic, strong) Recipient *recipient;
- (IBAction)deleteButtonClicked:(UIButton *)sender;

@end

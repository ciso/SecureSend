//
//  UserSettingsViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSettingsViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIViewController *sender;

- (IBAction)doneButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender;

@end

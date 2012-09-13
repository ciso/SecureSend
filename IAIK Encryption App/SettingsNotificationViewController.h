//
//  SettingsNotificationViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 13.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsNotificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonOutlet;
@property (nonatomic, strong) UIViewController *sender;

- (IBAction)buttonPressed:(UIButton *)sender;

@end

//
//  NotificationViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 20.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *buttonOutlet;
- (IBAction)buttonClicked:(id)sender;

@property (nonatomic, strong) id delegate;

@end

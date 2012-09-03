//
//  DeveloperViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 21.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeveloperViewController : UIViewController
- (IBAction)resetUserDefaults:(UIButton *)sender;
- (IBAction)openFeedback:(UIButton *)sender;
- (IBAction)deleteAllCertificates:(UIButton *)sender;
- (IBAction)resetkeychainButton:(UIButton *)sender;

@end

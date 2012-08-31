//
//  InfoViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 31.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)feedbackButtonClicked:(UIBarButtonItem *)sender;

@end

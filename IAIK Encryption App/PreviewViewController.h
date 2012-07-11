//
//  PreviewViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 13.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoosedContainerDelegate.h"

@interface PreviewViewController : UIViewController <UIPopoverControllerDelegate, UITextFieldDelegate,ChoosedContainerDelegate>
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;

@property(nonatomic,retain) UIImageView* image;
@property(nonatomic,retain) NSString* path;
@property(nonatomic,retain) UIWebView* webview;

- (void)refreshPreview;

//iPad
@property (nonatomic, assign) BOOL displayContainerView;
@property (nonatomic,retain) NSURL* receivedFileURL;
@property (nonatomic, strong) NSMutableArray *secureContainers;

- (IBAction)buttonEncryptAndSend:(id)sender;

- (void)showContainerView;


@end
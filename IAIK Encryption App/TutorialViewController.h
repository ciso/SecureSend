//
//  TutorialViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 20.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetStartedBaseViewController.h"

@interface TutorialViewController : GetStartedBaseViewController
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
- (IBAction)nextButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)skipButtonClicked:(UIBarButtonItem *)sender;

@end

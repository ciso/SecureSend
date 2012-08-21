//
//  GetStartedBaseViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 21.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetStartedBaseViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) BOOL isOnLastPage;

- (void)initialized;
- (void)next;

@end

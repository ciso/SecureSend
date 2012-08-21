//
//  GetStartedBaseViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 21.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "GetStartedBaseViewController.h"

@interface GetStartedBaseViewController ()

@end

@implementation GetStartedBaseViewController

@synthesize pageControl = _pageControl;
@synthesize scrollView  = _scrollView;
@synthesize pages       = _pages;

#pragma mark - Custom getter & setter
- (NSMutableArray*)pages {
    if (_pages == nil) {
        _pages = [[NSMutableArray alloc] init];
    }
    return _pages;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

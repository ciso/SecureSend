//
//  GetStartedBaseViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 21.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "GetStartedBaseViewController.h"

@interface GetStartedBaseViewController ()

@property (nonatomic, assign) NSInteger lastPage;

@end

@implementation GetStartedBaseViewController

@synthesize pageControl  = _pageControl;
@synthesize scrollView   = _scrollView;
@synthesize pages        = _pages;
@synthesize delegate     = _delegate;
@synthesize lastPage     = _lastPage;
@synthesize isOnLastPage = _isOnLastPage;

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
}

- (void)initialized {
    self.scrollView.delegate = self;
    
    NSInteger counter = 0;
    for (UIImage *image in self.pages ) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * counter++;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:frame];
        imageview.image = image;
        
        [self.scrollView addSubview:imageview];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.pages.count, self.scrollView.frame.size.height);
    
    self.pageControl.numberOfPages = self.pages.count;
}

- (void)next {
    
    if (self.pageControl.currentPage + 1 >= self.pages.count) { //we are on the last page        
        //informing delegate view controller
        if ([self.delegate respondsToSelector:@selector(userClickedNextOnLastPage)]) {
            [self.delegate performSelector:@selector(userClickedNextOnLastPage)];
        }
        else {
            NSLog(@"Method not implemented in delegate view controller (userClickedNextOnLastPage)!");
        }
    }
    else { //there is still a page
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * (self.pageControl.currentPage + 1); //added +1
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
    

    
//    NSLog(@"current page: %d", self.pageControl.currentPage + 1);
//    if (self.pageControl.currentPage + 1 == self.pages.count - 1) {
//        NSLog(@"last page");
//    }
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    //checking if last page is fully displayed
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * (self.pages.count - 1);
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    
    //NSLog(@"view: %f, frame: %f", self.scrollView.contentOffset.x, frame.origin.x);
    
    if (self.scrollView.contentOffset.x == frame.origin.x) {
        if ([self.delegate respondsToSelector:@selector(userEnteredLastPage)]) {
            [self.delegate performSelector:@selector(userEnteredLastPage)];
        }
        self.isOnLastPage = YES;
    }
    
    //NSLog(@"last: %d, current: %d", self.lastPage, self.pageControl.currentPage);
    if (self.lastPage == self.pages.count - 1 && self.lastPage > self.pageControl.currentPage)  {
        if ([self.delegate respondsToSelector:@selector(userLeftLastPage)]) {
            [self.delegate performSelector:@selector(userLeftLastPage)];
        }
        self.isOnLastPage = NO;
    }
    
    self.lastPage = self.pageControl.currentPage;
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

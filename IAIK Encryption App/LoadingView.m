//
//  LoadingView.m
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (UIView*)showLoadingViewInView:(UIView*)aView withMessage:(NSString*) message 
{
    //creating clear containerview
    UIView *newView = [[UIView alloc] init];
    CGRect newFrame;
    //calculating size and center
    newFrame.size.width = aView.frame.size.width / 1.7;
    newFrame.size.height = newFrame.size.width;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    newView.frame = newFrame;
    
    //defining new center
    CGPoint newCenter;
    newCenter.x = aView.frame.size.width / 2;
    newCenter.y = aView.frame.size.height / 2;
    
    //setting backgroundcolor and resizing options
    newView.center = newCenter;
    [newView setBackgroundColor:[UIColor clearColor]];
     newView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //defining overlay-view graying view out
    UIView* overlayview = [[UIView alloc] initWithFrame:newView.frame];
    newCenter.x = newView.frame.size.width / 2;
    newCenter.y = newView.frame.size.height / 2;
    overlayview.center = newCenter;
    overlayview.layer.cornerRadius = 20;
    overlayview.opaque = NO;
    overlayview.backgroundColor = [UIColor blackColor];
    overlayview.alpha = 0.6;
    [newView addSubview:overlayview];
    [newView sendSubviewToBack:overlayview];    
    
    //creating activityindicator and starting it
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    newCenter.y = newCenter.y * 0.8;
    activityIndicator.center = newCenter;
    [activityIndicator startAnimating];
    [newView addSubview:activityIndicator];    
    
    //creating message label and initialising it
    UILabel* messageLabel = [[UILabel alloc] init];
    
    message = [message stringByAppendingString:@"..."];
    
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont boldSystemFontOfSize:17];
    
    messageLabel.opaque = NO;
    messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = UITextAlignmentCenter;
    
    messageLabel.text = message;
    
    NSUInteger maxLabelWidth = (NSUInteger)(newView.frame.size.width * 0.75);
    
    CGSize maximumLabelSize = CGSizeMake(maxLabelWidth,9999);
    
    CGSize expectedLabelSize = [messageLabel.text sizeWithFont:messageLabel.font 
                                             constrainedToSize:maximumLabelSize 
                                                 lineBreakMode:messageLabel.lineBreakMode]; 
    
    //adjust the label the the new height.
    CGRect newLabelFrame = messageLabel.frame;
    newLabelFrame.size = expectedLabelSize;
    messageLabel.frame = newLabelFrame;
    
    messageLabel.center = CGPointMake(newCenter.x, roundf(newView.frame.size.height * 0.75));
    
    [newView addSubview:messageLabel];
        
    //adding view to passed view
    [aView addSubview:newView];
    
    return newView;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

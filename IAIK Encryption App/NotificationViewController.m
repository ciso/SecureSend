//
//  NotificationViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 20.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NotificationViewController.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController
@synthesize buttonOutlet = _buttonOutlet;
@synthesize delegate     = _delegate;

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
    
    self.view.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    
    //setting up button
    self.buttonOutlet.layer.cornerRadius = 5.0;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.buttonOutlet.layer.bounds;
    
    NSLog(@"%f, %f", self.buttonOutlet.layer.bounds.size.width, self.buttonOutlet.layer.bounds.size.height);
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithRed:58.0f/255.0f green:199.0f/255.0f blue:84.0f/255.0f alpha:1.0f].CGColor,
                            (id)[UIColor colorWithRed:0.0f/255.0f green:138/255.0f blue:24/255.0f alpha:1.0f].CGColor,
//                            (id)[UIColor colorWithHue:131 saturation:71/100.0f brightness:78/100.0f alpha:1.0f].CGColor,
//                            (id)[UIColor colorWithHue:130 saturation:100/100.0f brightness:54/100.0f alpha:1.0f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    gradientLayer.cornerRadius = self.buttonOutlet.layer.cornerRadius;
//    [self.buttonOutlet.layer addSublayer:gradientLayer];
    [self.buttonOutlet.layer insertSublayer:gradientLayer atIndex:0];
    
    self.buttonOutlet.layer.masksToBounds = YES;
    
    //text shadow
    self.buttonOutlet.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.buttonOutlet.titleLabel.layer.shadowOpacity = 0.3f;
    self.buttonOutlet.titleLabel.layer.shadowRadius = 1;
    self.buttonOutlet.titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    
    //border
    self.buttonOutlet.layer.borderColor = [UIColor colorWithRed:2/255.0f green:73/255.0f blue:14/255.0f alpha:0.5f].CGColor;
    self.buttonOutlet.layer.borderWidth = 1.0f;
    
    
    
//    
//    self.buttonOutlet.layer.shadowColor = [UIColor greenColor].CGColor;
//    self.buttonOutlet.layer.shadowOpacity = 0.8;
//    self.buttonOutlet.layer.shadowRadius = 12;
//    self.buttonOutlet.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
    
    
    
    
}

- (void)viewDidUnload
{
    [self setButtonOutlet:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)buttonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:NO];
    [self.delegate performSelector:@selector(notificationViewClosed)];
}
@end

//
//  SwipeCell.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SwipeCell.h"

#define DURATION 0.15f

@interface SwipeCell()

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIView *editView;

@end

@implementation SwipeCell

@synthesize editable = _editable;
@synthesize editView = _editView;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UISwipeGestureRecognizer *_swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
        _swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:_swipeRight];
        UISwipeGestureRecognizer *_swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
        _swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:_swipeLeft];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        //[self initSwipeView]; //initializing swipe view
        
        //[self.editView addGestureRecognizer:_swipeLeft];
        //[self.editView addGestureRecognizer:_swipeRight];
        
        
        
        
        
        //adding labels and textfields
        UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 23, 255, 30)];
        nameTextField.tag = 100;
        nameTextField.font = [UIFont boldSystemFontOfSize:18];
        
        [self.contentView addSubview:nameTextField];
        
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 265, 20)];
        dateLabel.tag = 101;
        dateLabel.font = [UIFont systemFontOfSize:14];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:dateLabel];
        
        UILabel *modifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 43, 265, 20)];
        modifiedLabel.tag = 102;
        modifiedLabel.font = [UIFont systemFontOfSize:14];
        modifiedLabel.textColor = [UIColor grayColor];
        modifiedLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:modifiedLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (!self.editable) {
        [super setSelected:selected animated:animated];
    }
    
    // Configure the view for the selected state
}

- (void)hideAnimated:(BOOL)animate {
    
    if (!animate) {
        self.editView.hidden = YES;
        self.editable = NO;
    }
    else {
        self.editView.alpha = 1.0f;
        
        [UIView animateWithDuration:DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.editView setAlpha:0.0f];
                         }
                         completion:^(BOOL finished){
                             self.editView.hidden = YES;
                         }];
        
        self.editable = NO;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

}

- (void)swipe {
    
    [self.delegate performSelector:@selector(cellSwiped:) withObject:self];
    
    //fade out
    if (self.editable) {
        
        self.editView.alpha = 1.0f;
        
        [UIView animateWithDuration:DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.editView setAlpha:0.0f];
                         }
                         completion:^(BOOL finished){
                             self.editView.hidden = YES;
                        }];
        
        self.editable = NO;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else { //fade in
        self.editView.hidden = NO;
        self.editView.alpha = 0.0f;
        
        //check if it is the last cell
        UITableView *tableView = (UITableView*)self.superview;
        NSInteger cells = [tableView numberOfRowsInSection:0];
        NSIndexPath *indexPath = [tableView indexPathForCell:self];
        
        CGRect maskFrame = self.editView.bounds;
        CGFloat radius = 0.0;

        if (indexPath.row == 0) {
            radius = 10.0;
            maskFrame.size.height += radius;
            maskFrame.origin.y += 1;
        }
        else if (indexPath.row == cells - 1) {
            radius = 10.0;
            maskFrame.size.height += radius;
            maskFrame.origin.y -= radius;
        }
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.cornerRadius = radius;
        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        maskLayer.frame = maskFrame;
        
        // set the mask
        self.editView.layer.mask = maskLayer;
        
        // Add a backaground color just to check if it works
        self.editView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg"]];

        
        

        
        UIButton *button1 = (UIButton*)[self.editView viewWithTag:401];
        UIButton *button2 = (UIButton*)[self.editView viewWithTag:402];
        UIButton *button3 = (UIButton*)[self.editView viewWithTag:403];
        UIButton *button4 = (UIButton*)[self.editView viewWithTag:404];
        
        button1.transform = CGAffineTransformMakeScale(1.5, 1.5);
        button2.transform = CGAffineTransformMakeScale(1.5, 1.5);
        button3.transform = CGAffineTransformMakeScale(1.5, 1.5);
        button4.transform = CGAffineTransformMakeScale(1.5, 1.5);
        
        [UIView animateWithDuration:DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.editView setAlpha:1.0f];
                             button1.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             button2.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             button3.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             button4.transform = CGAffineTransformMakeScale(1.0, 1.0);

                         }
                         completion:nil];
        
        self.editable = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
}

- (void)back {
    NSLog(@"back");
    
    [self swipe];
}

- (void)edit {
    NSLog(@"Edit");
    [self.delegate performSelector:@selector(edit:) withObject:self];
}

- (void)share {
    NSLog(@"Share");
    [self.delegate performSelector:@selector(share:) withObject:self];
}

- (void)delete {
    NSLog(@"Delete");
    [self.delegate performSelector:@selector(remove:) withObject:self];
}

- (void)initSwipeView {
    
    //NSLog(@"size: %f, %f, origin: %f, %f", self.frame.size.width, self.frame.size.height, self.frame.origin.x, self.frame.origin.y);
    
    CGRect rect = CGRectMake(10, 0, 300, 69);
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.tag = 500;
    //view.backgroundColor = [UIColor underPageBackgroundColor]; //[UIColor greenColor];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg"]];

    
    view.hidden = YES;
    
    //adding back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(1, 7, 60, 60);
    backButton.tag = 401;
    [backButton setImage:[UIImage imageNamed:@"213-reply"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:backButton];
    
    //adding edit button
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(75, 6, 60, 60);
    editButton.tag = 402;
    [editButton setImage:[UIImage imageNamed:@"187-pencil"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:editButton];
    
    //adding share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(160, 5, 60, 60);
    shareButton.tag = 403;
    [shareButton setImage:[UIImage imageNamed:@"266-upload"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:shareButton];
    
    
    //adding delete button
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(235, 5, 60, 60);
    deleteButton.tag = 404;
    [deleteButton setImage:[UIImage imageNamed:@"218-trash2"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:deleteButton];
    
    //adding swipe gestures
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.editView = view;
    
    [self.editView addGestureRecognizer:swipeRight];
    [self.editView addGestureRecognizer:swipeLeft];
    
    [self addSubview:view];
    //[self sendSubviewToBack:view];
    
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self initSwipeView];
}

@end

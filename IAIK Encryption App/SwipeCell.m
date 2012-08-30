//
//  SwipeCell.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

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

- (void)swipe {
    
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
    }
    else {
        self.editView.hidden = NO;
        self.editView.alpha = 0.0f;

        [UIView animateWithDuration:DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.editView setAlpha:1.0f];
                         }
                         completion:nil];
        
        self.editable = YES;
    }
    
}

- (void)back {
    NSLog(@"back");
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
    view.backgroundColor = [UIColor underPageBackgroundColor]; //[UIColor greenColor];
    //view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg"]];

    
    view.hidden = YES;
    
    //adding back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(20, 15, 60, 30);
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:backButton];
    
    //adding edit button
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editButton.frame = CGRectMake(100, 15, 60, 30);
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:editButton];
    
    //adding delete button
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteButton.frame = CGRectMake(170, 8, 50, 30);
    [deleteButton setTitle:@"Del" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:deleteButton];
    
    //adding share button
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(230, 8, 50, 50);
    [shareButton setImage:[UIImage imageNamed:@"export"] forState:UIControlStateNormal];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:shareButton];
    
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

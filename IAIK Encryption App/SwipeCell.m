//
//  SwipeCell.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SwipeCell.h"

@interface SwipeCell()

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIView *editView;

@end

@implementation SwipeCell

@synthesize editable = _editable;
@synthesize editView = _editView;

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
        [self initSwipeView]; //initializing swipe view
        
        //[self.editView addGestureRecognizer:_swipeLeft];
        //[self.editView addGestureRecognizer:_swipeRight];
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
        self.editView.hidden = YES;

        self.editable = NO;
    }
    else {
        self.editView.hidden = NO;
        
        self.editable = YES;
    }
    
}

- (void)dup {
    NSLog(@"dup");
}

- (void)initSwipeView {
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = [UIColor greenColor];
    view.hidden = YES;
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:view action:@selector(dup)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:view action:@selector(dup)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    
    self.editView = view;
    
    [self.editView addGestureRecognizer:swipeRight];
    [self.editView addGestureRecognizer:swipeLeft];
    
    [self addSubview:view];
}

@end

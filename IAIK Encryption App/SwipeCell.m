//
//  SwipeCell.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SwipeCell.h"

@implementation SwipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        // Recognizing right swiping gestures
        UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
        // right swipe direction is default
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:rightSwipeGestureRecognizer];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)rightSwipe:(id)sender {
    NSLog(@"swiped");
}

@end

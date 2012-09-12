//
//  SwipeCell.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 29.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwipeCellDelegate <NSObject>

@required
- (void)share:(UITableViewCell*)cell;
- (void)remove:(UITableViewCell*)cell;
- (void)edit:(UITableViewCell*)cell;

- (void)cellSwiped:(UITableViewCell*)cell;

@end

@interface SwipeCell : UITableViewCell

@property (nonatomic, strong) id delegate;

- (void)hideAnimated:(BOOL)animate;

@end

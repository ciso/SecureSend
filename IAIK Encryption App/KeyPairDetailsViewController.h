//
//  KeyPairDetailsViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 01.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyPair;

@interface KeyPairDetailsViewController : UITableViewController

@property (nonatomic, strong) KeyPair *keyPair;

@end

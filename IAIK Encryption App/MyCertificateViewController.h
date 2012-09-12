//
//  MyCertificateViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothConnectionHandler.h"

@interface MyCertificateViewController : UITableViewController

@property (nonatomic, strong) BluetoothConnectionHandler* btConnectionHandler;


@end

//
//  CertificateActionViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 13.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "BluetoothConnectionHandler.h"

@interface CertificateActionViewController : UITableViewController <BluetoothConnectionHandlerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) BluetoothConnectionHandler* btConnectionHandler;

@property (nonatomic, strong) NSData* receivedCertificateData;


@end

//
//  ChooseSendMethodViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothConnectionHandler.h"
#import <AddressBookUI/AddressBookUI.h>


@interface ChooseSendMethodViewController : UITableViewController <BluetoothConnectionHandlerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) BluetoothConnectionHandler* btConnectionHandler;
@property (nonatomic, strong) NSData* receivedCertificateData;



@end

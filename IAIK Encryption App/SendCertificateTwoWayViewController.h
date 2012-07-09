//
//  SendCertificateTwoWayViewController.h
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface SendCertificateTwoWayViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* emailAddress;
@property (nonatomic,retain) NSString* phoneNumber;

@property (nonatomic,retain) NSArray* phoneNumbers;
@property (nonatomic,retain) NSArray* emailAddresses;

@property (nonatomic,retain) NSString* key;

-(IBAction)didCancel:(id)sender;

@end

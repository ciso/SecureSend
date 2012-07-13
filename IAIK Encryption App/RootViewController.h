//
//  RootViewController.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class SecureContainer;
#import "BluetoothConnectionHandler.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ChoosedContainerDelegate.h"
#import <MessageUI/MessageUI.h>

#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"
#define SEGUE_TO_DETAIL @"toDetailViewController"
#define SEGUE_TO_CERT_ASS @"toCertSendAssist"
#define SEGUE_TO_CREATE_CERT @"toCreateCertificate"
#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"
#define SEGUE_TO_CERT_REQUEST @"toCertRequest"
#define SEGUE_TO_DEFAULT_EMAIL @"toDefaultEmail"


@class BluetoothConnectionHandler;

@interface RootViewController : UITableViewController <BluetoothConnectionHandlerDelegate,ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate,ChoosedContainerDelegate>


@property (nonatomic, strong) BluetoothConnectionHandler* btConnectionHandler;
@property (nonatomic, strong) NSData* receivedCertificateData;
@property (nonatomic, strong) NSMutableArray* containers;
@property (nonatomic, strong) NSData* certData;
@property (nonatomic, strong) NSURL* receivedFileURL;
@property (nonatomic, strong) NSString *phoneNumber;


- (void)receivedBluetoothData:(NSData*) data;
- (void)sendCertificateBluetooth;
- (void)sendCertificateMailTextMessage;
- (void)editTableView;
- (void)showEditBarButtonItem;
- (void)showDoneBarButtonItem;
- (void)decryptContainer:(NSData*) encryptedContainer;
- (void)manageCertificateRequest:(NSData*)request;
- (BOOL)isDataProtectionEnabled;
@end
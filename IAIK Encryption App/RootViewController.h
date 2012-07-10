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

#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"
#define SEGUE_TO_DETAIL @"toDetailViewController"
#define SEGUE_TO_CERT_ASS @"toCertSendAssist"
#define SEGUE_TO_CREATE_CERT @"toCreateCertificate"
#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"


@class BluetoothConnectionHandler;

@interface RootViewController : UITableViewController <BluetoothConnectionHandlerDelegate,ABPeoplePickerNavigationControllerDelegate,UIAlertViewDelegate,ChoosedContainerDelegate>


@property (nonatomic,retain) BluetoothConnectionHandler* btConnectionHandler;
@property (nonatomic,retain) NSData* receivedCertificateData;
@property (nonatomic,retain) NSMutableArray* containers;
@property (nonatomic,retain) NSData* certData;
@property (nonatomic,retain) NSURL* receivedFileURL;


-(void) receivedBluetoothData:(NSData*) data;
-(void) sendCertificateBluetooth;
-(void) sendCertificateMailTextMessage;
-(void) editTableView;
-(void) showEditBarButtonItem;
-(void) showDoneBarButtonItem;
-(void) decryptContainer:(NSData*) encryptedContainer;

-(BOOL) isDataProtectionEnabled;
@end
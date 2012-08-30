//
//  RootViewController.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <DropboxSDK/DropboxSDK.h>
#import "BluetoothConnectionHandler.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ChoosedContainerDelegate.h"
#import <MessageUI/MessageUI.h>
#import "SwipeCell.h"

#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"
#define SEGUE_TO_DETAIL @"toDetailViewController"
#define SEGUE_TO_CERT_ASS @"toCertSendAssist"
#define SEGUE_TO_CREATE_CERT @"toCreateCertificate"
#define SEGUE_TO_CHOOSE_CONTROLLER @"toChooseContainer"
#define SEGUE_TO_CERT_REQUEST @"toCertRequest"
#define SEGUE_TO_DEFAULT_EMAIL @"toDefaultEmail"

@class SecureContainer;
@class BluetoothConnectionHandler;

@interface RootViewController : UITableViewController <BluetoothConnectionHandlerDelegate,ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate,ChoosedContainerDelegate, UITextFieldDelegate, DBRestClientDelegate, SwipeCellDelegate>
{
    //DBRestClient *restClient; //dropbox sdk
}

@property (nonatomic, strong) BluetoothConnectionHandler* btConnectionHandler;
@property (nonatomic, strong) NSData* receivedCertificateData;
@property (nonatomic, strong) NSMutableArray* containers;
@property (nonatomic, strong) NSData* certData;
@property (nonatomic, strong) NSURL* receivedFileURL;
@property (nonatomic, assign) BOOL sendRequest;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL certMailSent;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *hash;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) DBRestClient *restClient;

- (void)receivedBluetoothData:(NSData*) data;
- (void)sendCertificateBluetooth;
- (void)sendCertificateMailTextMessage;
- (void)editTableView;
- (void)showEditBarButtonItem;
- (void)showDoneBarButtonItem;
- (void)decryptContainer:(NSData*) encryptedContainer;
- (void)manageCertificateRequest:(NSData*)request;
- (BOOL)isDataProtectionEnabled;
- (IBAction)addNewContainer:(UIBarButtonItem *)sender;

//test
- (void)uploadFileToDropbox:(NSData*)encryptedContainer withName:(NSString*)name;
@end
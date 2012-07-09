//
//  ContainerDetailViewController.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifyCertPropertyDelegate.h"
#import "ModifyContainerPropertyDelegate.h"
#import <MessageUI/MessageUI.h>

@class SecureContainer, NameCell;

@interface ContainerDetailViewController : UITableViewController <ModifyContainerPropertyDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,ModifyCertPropertyDelegate,UITextFieldDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) SecureContainer* container;
@property (nonatomic, strong) NSData* currentCertificate;

- (void) setCert: (NSData*) cert;
- (IBAction) addFile;

// iPad
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addFileButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (nonatomic, assign) BOOL show;

- (IBAction)addFileButtonAction:(id)sender;
- (void)hide;

@end

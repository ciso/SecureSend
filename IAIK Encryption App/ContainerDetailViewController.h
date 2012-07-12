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
#import "MWPhotoBrowser.h"

@class SecureContainer, NameCell;

@interface ContainerDetailViewController : UITableViewController <ModifyContainerPropertyDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, ModifyCertPropertyDelegate, UITextFieldDelegate, UIPopoverControllerDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) SecureContainer* container;
@property (nonatomic, strong) NSData* currentCertificate;
@property (nonatomic, retain) NSArray *photos;


- (void) setCert: (NSData*) cert;
- (IBAction) addFile;

@end

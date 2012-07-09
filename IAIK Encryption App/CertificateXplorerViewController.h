//
//  CertificateXplorerViewController.h
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 11.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifyCertPropertyDelegate.h"
#import <MessageUI/MessageUI.h>


@interface CertificateXplorerViewController : UITableViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>


@property (nonatomic,retain) NSMutableArray* relevantPeople;
@property (nonatomic,retain) NSMutableArray* expirationDates;
@property (nonatomic,assign) id<ModifyCertPropertyDelegate> delegate;

-(IBAction)didCancel:(id)sender;


@end

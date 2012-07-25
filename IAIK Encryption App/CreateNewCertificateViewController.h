//
//  CreateNewCertificateViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 24.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    kFieldFirstName,
    kFieldLastName,
    kFieldEmail,
    kFieldRepeatEmail,
    kFieldCountry,
    kFieldCity,
    kFieldOrganization,
    kFieldOrganizationUnit
} FieldTypes;

@interface CreateNewCertificateViewController : UITableViewController <UITextFieldDelegate>

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender;

@end

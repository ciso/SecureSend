//
//  CreateCertificateViewController.h
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateCertificateViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic,retain) IBOutlet UITextField* firstname;
@property (nonatomic,retain) IBOutlet UITextField* lastname;
@property (nonatomic,retain) IBOutlet UITextField* emailaddress;

@property (nonatomic,retain) IBOutlet UITextField* city;
@property (nonatomic,retain) IBOutlet UITextField* countrycode;
@property (nonatomic,retain) IBOutlet UITextField* organisation;
@property (nonatomic,retain) IBOutlet UITextField* organisationalunit;

@property (nonatomic,retain) IBOutlet UIScrollView* scrollview;


- (IBAction)savePressed:(id)sender;

- (IBAction)cancelPressed:(id)sender;

@end

//
//  CreateCertificateViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateCertificateViewController.h"
#import "Crypto.h"
#import "FilePathFactory.h"
#import "LoadingView.h"
#import "KeyChainStore.h"
#import "PersistentStore.h"

//todo: just temp! remove in final
#include <openssl/cms.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/pem.h>
#include <openssl/err.h>

@implementation CreateCertificateViewController

@synthesize firstname = _firstname,lastname = _lastname,emailaddress= _emailaddress,city = _city,countrycode = _countrycode,organisation = _organisation,organisationalunit = _organisationalunit, scrollview = _scrollview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollview.contentSize = CGSizeMake(320, 650);
    
    //TODO
    //remove this in final
    [self fillWithTempData];
    
}

- (void)fillWithTempData
{
    //TODO
    self.firstname.text = @"Christof";
    self.lastname.text = @"Stromberger";
    self.emailaddress.text = @"stromberger@student.tugraz.at";
    
    self.city.text = @"Graz";
    self.countrycode.text = @"AT";
    self.organisation.text = @"TU Graz";
    self.organisationalunit.text = @"IT Security";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - IBAction methods

- (IBAction)cancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)savePressed:(id)sender {
    
    if(self.firstname.text.length == 0 || self.lastname.text.length == 0|| self.emailaddress.text.length == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mandatory data not present", @"Title of alert view in create certificate view") 
                                                        message:NSLocalizedString(@"Please enter all required data to generate the certificate", @"Message of alert view in create certificate view") 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    else 
    {     
        //creating certificate from user input
        Crypto *crypto = [Crypto getInstance];
        
        UIView* load = [LoadingView showLoadingViewInView:self.view withMessage:NSLocalizedString(@"Creating Certificate", @"Loading text in create certificate view")];
        
        //running key and cert generation in own thread
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //create a rsa key
            NSData *key = [crypto createRSAKeyWithKeyLength:2048];
                        
            //[KeyChainStore setData:key forKey:<#(NSString *)#> type:<#(KeyChainDataType)#>]
            
            //create new certificate based on the before created key
            NSData* cert = [crypto createX509CertificateWithPrivateKey:key 
                                                              withName:self.firstname.text
                                                          emailAddress:self.lastname.text
                                                               country:self.countrycode.text 
                                                                  city:self.city.text
                                                          organization:self.organisation.text
                                                      organizationUnit:self.organisationalunit.text];
            
            
            if (![PersistentStore storeForUserCertificate:cert privateKey:key])
            {
                NSLog(@"Storing certificate and private key failed!");
            }
            
            dispatch_async( dispatch_get_main_queue(), ^{

                [load removeFromSuperview];
                
                [self dismissModalViewControllerAnimated:YES];
                
            });
        });

    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) dealloc
{
    self.firstname = nil;
    self.lastname = nil;
    self.emailaddress = nil;
    self.organisation = nil;
    self.organisationalunit = nil;
    self.countrycode = nil;
    self.city = nil;
}

@end

//
//  AppDelegate.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 09.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

#define EXTENSION_CERT @"iaikcert"
#define EXTENSION_CONTAINER @"iaikcontainer"
#define EXTENSION_PDF @"pdf"


@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    BOOL shownotification = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    // Get current version ("Bundle Version") from the default Info.plist file
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *prevStartupVersions = [[NSUserDefaults standardUserDefaults] arrayForKey:@"prevStartupVersions"];
    if (prevStartupVersions == nil) 
    {
        //Fresh install!!
        shownotification = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:currentVersion] forKey:@"prevStartupVersions"];
    }
    else
    {
        if (![prevStartupVersions containsObject:currentVersion]) 
        {
            
            //first start of this version
            shownotification = YES;
            
            NSMutableArray *updatedPrevStartVersions = [NSMutableArray arrayWithArray:prevStartupVersions];
            [updatedPrevStartVersions addObject:currentVersion];
            [[NSUserDefaults standardUserDefaults] setObject:updatedPrevStartVersions forKey:@"prevStartupVersions"];
        }
    }
    
    // Save changes to disk
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(shownotification)
    {
        UIAlertView* enableDP = [[UIAlertView alloc] initWithTitle:@"Data Protection" message:@"If you currently don't have a passphrase set for your device do it now! This application can not be considered secure without this feature turned on" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [enableDP show];
    }
    

    UIImage *navbarportrait = [[UIImage imageNamed:@"NavBarIPad"] 
                               resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:navbarportrait forBarMetrics:UIBarMetricsDefault];
    
    UIImage *navbarlandscape = [[UIImage imageNamed:@"NavBarIPad"] 
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:navbarlandscape forBarMetrics:UIBarMetricsLandscapePhone];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - import files into this app
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    UINavigationController* navi = (UINavigationController*)self.window.rootViewController;
    RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
    id delegate;
    
    if([[url pathExtension] isEqual:EXTENSION_CERT])
    {
        //extracting certdata from inbox
        NSData* certdata = [[NSData alloc] initWithContentsOfURL:url];
        
    
        //setting certdata of rootviewcontroller
        root.certData = certdata;
        
        delegate = root;  
        
        //showing alert to enter code, setting rootviewcontroller as delegate
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Decrypt certificate" message:@"Please enter the PIN to decrypt the certificate-file: " delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Decrypt", nil];
        
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.delegate = delegate;
        [alert show];
                
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
    }
    else if([[url pathExtension] isEqual:EXTENSION_CONTAINER])
    {
        //extracting certdata from inbox
        NSData* containerdata = [[NSData alloc] initWithContentsOfURL:url];
        
             
        //getting rootviewcontroller
        UINavigationController* navi = (UINavigationController*)self.window.rootViewController;
        RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
        
        [root decryptContainer:containerdata];
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
    }
    else
    {
        [root performSegueWithIdentifier:SEGUE_TO_CHOOSE_CONTROLLER sender:url];
    }
    
    
    return YES;    
}


@end

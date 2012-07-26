//
//  AppDelegate.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 09.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <DropboxSDK/DropboxSDK.h>
#import "AppDelegate.h"
#import "RootViewController.h"
#import "NSData+CommonCrypto.h"
#import "Base64.h"
#import "RequestHandler.h"
#import "ContainerDetailViewController.h"
#import "SecureContainer.h"

#define EXTENSION_CERT @"iaikcert"
#define EXTENSION_CONTAINER @"iaikcontainer"
#define EXTENSION_REQUEST @"iaikreq"
#define EXTENSION_PDF @"pdf"


@implementation AppDelegate

@synthesize window = _window;
@synthesize reqHandler = _reqHandler;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

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
        UIAlertView* enableDP = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Data Protection", nil) message:NSLocalizedString(@"If you currently don't have a passphrase set for your device do it now! This application can not be considered secure without this feature turned on", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [enableDP show];
    }
    
    //navbar customization
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navigationBar"] 
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 
                                       forBarMetrics:UIBarMetricsDefault];

    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], 
      UITextAttributeTextColor, 
      [UIFont fontWithName:@"Arial-Bold" size:0.0], 
      UITextAttributeFont, 
      nil]];
    
    
    //barbutton item
    UIImage *button30 = [[UIImage imageNamed:@"buttonBackground"] 
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    UIImage *button24 = [[UIImage imageNamed:@"buttonBackground"] 
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:button24 forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsLandscapePhone];    
    
    //ui back button
    UIImage *backButton30 = [[UIImage imageNamed:@"backButton"] 
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)];
    UIImage *backButton24 = [[UIImage imageNamed:@"backButton"] 
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton30 forState:UIControlStateNormal 
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton24 forState:UIControlStateNormal 
                                                    barMetrics:UIBarMetricsLandscapePhone];
    
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], 
      UITextAttributeTextColor,
      [UIFont fontWithName:@"SystemBold" size:10.0], 
      UITextAttributeFont, 
      nil] 
                                                forState:UIControlStateNormal];
    
    
    //register settings bundle
    [self registerDefaultsFromSettingsBundle];
    
    
    //nope... no private api keys on github... :P
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *apiKeyFilePath = [bundle pathForResource:@"apikey" ofType:@"txt"];
    NSString *secretKeyFilePath = [bundle pathForResource:@"secretkey" ofType:@"txt"];
    
    NSError *error;
    NSString *apiKey = [NSString stringWithContentsOfFile:apiKeyFilePath encoding:NSUTF8StringEncoding error:&error];
    NSString *secretKey = [NSString stringWithContentsOfFile:secretKeyFilePath encoding:NSUTF8StringEncoding error:&error];
    
    //register dropbox
    DBSession* dbSession =
    [[DBSession alloc]
      initWithAppKey:apiKey
      appSecret:secretKey
      root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    
    [DBSession setSharedSession:dbSession];
    
    
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
    UITabBarController *tabBar = (UITabBarController*)self.window.rootViewController;
    UINavigationController* navi = (UINavigationController*)[tabBar.viewControllers objectAtIndex:0];
    RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
    id delegate;
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");

            ContainerDetailViewController *detailView = (ContainerDetailViewController*)[navi.viewControllers objectAtIndex:1];
            if ([detailView isKindOfClass:[ContainerDetailViewController class]])
            {
                NSData* encryptedcontainer = [detailView zipAndEncryptContainer];

                [root uploadFileToDropbox:encryptedcontainer withName:detailView.container.name];
            }

        }
        return YES;
    }

    
    if([[url pathExtension] isEqual:EXTENSION_CERT])
    {
        //extracting certdata from inbox
        NSData* certdata = [[NSData alloc] initWithContentsOfURL:url];
        NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH]; //CC_SHA256_DIGEST_LENGTH];
        
        CC_SHA1(certdata.bytes, certdata.length, hash.mutableBytes);
        
        NSString *base64hash = [Base64 encode:hash];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"checksum_verification"] == 1)
        {
            NSString *title = [NSString stringWithString:NSLocalizedString(@"You have been sent a verification SMS. Paste the SMS in the following textfield. The App verifies it for you.", 
                                                                           @"Title for alert view in app delegate")];
            
            //setting certdata of rootviewcontroller
            root.certData = certdata;
            
            delegate = root;
            
            //showing alert to enter code, setting rootviewcontroller as delegate
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:delegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button text in app delegate") 
                                                  otherButtonTitles:@"OK", nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
        else 
        {
            NSString *title = [NSString stringWithString:NSLocalizedString(@"You have been sent a verification SMS. Please check the following checksum and compare it.", 
                                                                           @"Title for alert view in app delegate")];
            NSString *message = [NSString stringWithFormat:@"%@", base64hash];
            
            //setting certdata of rootviewcontroller
            root.certData = certdata;
            
            delegate = root;
            
            //showing alert to enter code, setting rootviewcontroller as delegate
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
            
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
    }
    else if([[url pathExtension] isEqual:EXTENSION_CONTAINER])
    {
        //extracting certdata from inbox
        NSData* containerdata = [[NSData alloc] initWithContentsOfURL:url];
        
             
        //getting rootviewcontroller
        /*UINavigationController* navi = (UINavigationController*)self.window.rootViewController;
        RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
        */
        
        [root decryptContainer:containerdata];
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
    }
    else if([[url pathExtension] isEqual:EXTENSION_REQUEST])
    {
        NSData *request = [[NSData alloc] initWithContentsOfURL:url];
        //getting rootviewcontroller
        /*UINavigationController* navi = (UINavigationController*)self.window.rootViewController;
        RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
        */
        
        self.reqHandler = [[RequestHandler alloc] init];
        self.reqHandler.request = request;
        self.reqHandler.delegate = root;
        [self.reqHandler requestReceived]; 
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    else
    {
        [root performSegueWithIdentifier:SEGUE_TO_CHOOSE_CONTROLLER sender:url];
    }
    
    
    return YES;    
}


#pragma mark - user defaults (settings bundle)
- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}


#pragma mark - CoreData stuff
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SecureSendModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SecureSendStore.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    //assuming complete protection class for sqlite store
    
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
    if (![[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:[storeURL absoluteString] error:&error])
    {
        NSLog(@"Could not set protection class for core data db!");
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end

//
//  SourceSelectionViewController.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifyContainerPropertyDelegate.h"

@class SecureContainer;
@class ContainerDetailViewController;

@interface SourceSelectionViewController : UITableViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,assign) id<ModifyContainerPropertyDelegate> delegate;
@property (nonatomic,strong) NSString* basePath;
@property (nonatomic, strong) UIBarButtonItem *button;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) ContainerDetailViewController *caller;
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender;


@end

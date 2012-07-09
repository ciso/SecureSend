//
//  ChooseContainerViewController.h
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 17.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoosedContainerDelegate.h"

@interface ChooseContainerViewController : UITableViewController


@property (nonatomic,retain) NSArray* containers;
@property (nonatomic,assign) id<ChoosedContainerDelegate> delegate;

-(IBAction)didCancel:(id)sender;


@end

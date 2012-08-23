//
//  DropboxBrowserViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 23.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DropboxBrowserViewController.h"
#import "LoadingView.h"

@interface DropboxBrowserViewController ()

@property (nonatomic, strong) UIView *load;
@property (nonatomic, strong) NSArray *folders;

@end

@implementation DropboxBrowserViewController

@synthesize load    = _load;
@synthesize folders = _folders;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.load = [LoadingView showLoadingViewInView:self.view.window withMessage:@"Loading ..."];
    self.root.restClient.delegate = self;
    [self.root.restClient loadMetadata:@"/"];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.folders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    DBMetadata *file = [self.folders objectAtIndex:indexPath.row];
    cell.textLabel.text = file.filename;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [self.load removeFromSuperview];
    
    if (metadata.isDirectory) {
        
        self.folders = [NSArray arrayWithArray:metadata.contents];
        [self.tableView reloadData];
//        
//        NSLog(@"Folder '%@' contains:", metadata.path);
//        for (DBMetadata *file in metadata.contents) {
//            NSLog(@"\t%@", file.filename);
//        }
    }
}

- (void)restClient:(DBRestClient *)client
    loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
    [self.load removeFromSuperview]; //temp
    [self dismissModalViewControllerAnimated:YES]; //temp
}


@end

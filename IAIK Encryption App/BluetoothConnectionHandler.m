//
//  BluetoothConnectionHandler.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BluetoothConnectionHandler.h"

@interface BluetoothConnectionHandler (){
    
    BOOL isDeviceSender;
}

@end


@implementation BluetoothConnectionHandler

@synthesize peerPicker,peerSession, delegate, dataToSend;


- (id) init
{
    self = [super init];
    
    GKPeerPickerController* temppeerpicker = [[GKPeerPickerController alloc] init];
    self.peerPicker = temppeerpicker;    
    self.peerPicker.delegate = self;
    self.peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    self.peerSession = nil;
    self.dataToSend = nil;
    self.delegate = nil;
    
    isDeviceSender = NO;
    
    return self;
}

#pragma mark - GKPeerPickerControllerDelegate methods

- (void)peerPickerController:(GKPeerPickerController*)picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session {
    
    NSLog(@"didConnectPeertoSession");
    
    self.peerSession = session;
    
    session.delegate = self;
    
    // Remove the picker
    picker.delegate = nil;
    [picker dismiss];
    
    if(isDeviceSender)
    {
        [self.peerSession sendDataToAllPeers:self.dataToSend withDataMode:GKSendDataReliable error:nil];
                
        dataToSend = nil;
        
    }
    else
    {
        [self.peerSession setDataReceiveHandler:self withContext:nil];
    }
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
}

/*- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
 {
 if(!self.peerSession)
 {
 GKSession* session = [[GKSession alloc] initWithSessionID:@"IAIKBacTest" displayName:@"IAIK_BAC" sessionMode:GKSessionModePeer];
 self.peerSession = session;
 }
 
 return self.peerSession;
 
 }
 */

#pragma mark - GKSessionDelegate methods

- (void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateConnected:
            //[self.connectedPeers addObject:peerID];
            NSLog(@"Peer connected to session");
            break;
        case GKPeerStateDisconnected:
            //[self.connectedPeers removeObject:peerID];
            NSLog(@"Peer disconnected from session");
        default:
            break;
    }
    
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"didReceiveConnectionRequestFromPeer!!!!!!!!!!!!!!!!!!");
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    
    NSLog(@"connectionWithPeerFailed:");
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Bluetooth"
                          message: @"Bluetooth connection failed. Please try again."
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Bluetooth"
                          message: @"Bluetooth connection failed. Please try again."
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - DataReceiverHandler methods

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    if(![session.peerID isEqualToString:self.peerSession.peerID] || 
       ![session.sessionID isEqualToString:self.peerSession.sessionID])
    {
        NSLog(@"Received data from strange peer!!!");
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Bluetooth"
                              message: @"Error (#2305)"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self.delegate receivedBluetoothData:data];
        
    }
    
}

#pragma mark - Public methods

//works only for files < 78kByte
- (void) sendDataToAll: (NSData*) data
{
    isDeviceSender = YES;
    self.dataToSend = data;
    self.peerPicker.delegate = self;
    [self.peerPicker show];
    
}

- (void) receiveDataWithHandlerDelegate: (id<BluetoothConnectionHandlerDelegate>) newdelegate
{
    isDeviceSender = NO;
    self.delegate = newdelegate;
    self.peerPicker.delegate = self;
    [self.peerPicker show];
}

- (void) dealloc
{
    self.peerPicker = nil;
    self.peerSession = nil;
    self.dataToSend = nil;
    self.delegate = nil;
}



@end

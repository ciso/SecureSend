//
//  BluetoothConnectionHandler.h
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 23.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@protocol BluetoothConnectionHandlerDelegate <NSObject>

- (void) receivedBluetoothData: (NSData*) data;

@end


@interface BluetoothConnectionHandler : NSObject <GKPeerPickerControllerDelegate,GKSessionDelegate>

@property (nonatomic,retain) GKPeerPickerController* peerPicker;
@property (nonatomic,retain) GKSession* peerSession;
@property (nonatomic,retain) NSData* dataToSend;
@property (nonatomic,assign) id<BluetoothConnectionHandlerDelegate> delegate;


- (void) sendDataToAll: (NSData*) data;
- (void) receiveDataWithHandlerDelegate: (id<BluetoothConnectionHandlerDelegate>) newdelegate;

@end


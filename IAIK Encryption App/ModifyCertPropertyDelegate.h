//
//  ModifyCertPropertyDelegate.h
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModifyCertPropertyDelegate <NSObject>

-(void) setCert: (NSData*) cert;

@end

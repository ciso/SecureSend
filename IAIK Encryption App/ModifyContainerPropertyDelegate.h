//
//  ModifyContainerPropertyDelegate.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModifyContainerPropertyDelegate <NSObject>

-(void) addFilesToContainer:(NSArray*) filePaths;

@end

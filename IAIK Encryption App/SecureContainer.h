//
//  SecureContainer.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecureContainer : NSObject

@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) NSMutableArray* fileUrls;
@property(nonatomic,retain) NSString* basePath;
@property(nonatomic,retain) NSDate* creationDate;

- (void)reloadFiles;

@end

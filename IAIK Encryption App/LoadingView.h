//
//  LoadingView.h
//  IAIK Encryption App
//
//  Created by Christoph Hechenblaikner on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView


+ (UIView*)showLoadingViewInView:(UIView*)aView withMessage:(NSString*) message ;

@end

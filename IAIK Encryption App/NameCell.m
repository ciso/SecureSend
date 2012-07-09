//
//  NameCell.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 08.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NameCell.h"

@implementation NameCell

@synthesize nameField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

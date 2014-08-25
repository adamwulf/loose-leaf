//
//  MMCloudKitFriendTableViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitFriendTableViewCell.h"
#import "MMTextButton.h"

@implementation MMCloudKitFriendTableViewCell{
    UILabel* textLabel;
    MMSidebarButton* avatarButton;
}

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        CGRect lblFr = self.bounds;
        lblFr.origin.x = 76;
        lblFr.size.width -= 76;
        textLabel = [[UILabel alloc] initWithFrame:lblFr];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        avatarButton = [[MMTextButton alloc] initWithFrame:CGRectMake(0, 0, 76, 76) andFont:[UIFont systemFontOfSize:20] andLetter:@"AW" andXOffset:0 andYOffset:0];
        
        [self addSubview:textLabel];
        [self addSubview:avatarButton];
    }
    return self;
}


-(UILabel*) textLabel{
    return textLabel;
}



@end

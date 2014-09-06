//
//  MMCloudKitFriendTableViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitFriendTableViewCell.h"
#import "UIView+Debug.h"
#import "UIView+Animations.h"
#import "CKDiscoveredUserInfo+Initials.h"
#import "Constants.h"

@implementation MMCloudKitFriendTableViewCell{
    UILabel* textLabel;
    MMAvatarButton* avatarButton;
}

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        CGRect lblFr = self.bounds;
        lblFr.origin.x = 76;
        lblFr.size.width -= 76;
        textLabel = [[UILabel alloc] initWithFrame:lblFr];
        textLabel.font = [UIFont systemFontOfSize:20];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

        [self addSubview:textLabel];
    }
    return self;
}

-(void) setUserInfo:(NSDictionary*)userInfo forIndex:(NSInteger)index{
    CGFloat height = self.bounds.size.height - kWidthOfSidebarButtonBuffer / 4.0;
    [avatarButton removeFromSuperview];
    avatarButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, height, height) forLetter:[userInfo objectForKey:@"initials"]];
    [self addSubview:avatarButton];

    CGRect lblFr = textLabel.frame;
    lblFr.origin.x = height;
    lblFr.size.width = self.bounds.size.width - height;
    textLabel.frame = lblFr;
    
    textLabel.text = [NSString stringWithFormat:@"%@ %@", [userInfo objectForKey:@"firstName"], [userInfo objectForKey:@"lastName"]];
    // fit width
    [textLabel sizeToFit];
    CGRect fr = textLabel.frame;
    fr.size.height = self.bounds.size.height;
    textLabel.frame = fr;
}

-(void) bounce{
    [avatarButton bounceButton];
    [textLabel bounceWithTransform:CGAffineTransformIdentity stepOne:.2 stepTwo:-.1];
}

-(MMAvatarButton*) stealAvatarButton{
    MMAvatarButton* ret = avatarButton;
    avatarButton = nil;
    return ret;
}


#pragma mark - UITouch Control

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return [super pointInside:point withEvent:event];
}

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if([super hitTest:point withEvent:event]){
        return self;
    }
    return nil;
}

@end

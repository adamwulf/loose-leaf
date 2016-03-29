//
//  MMStackPropertiesView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackPropertiesView.h"
#import "MMAllStacksManager.h"
#import <JotUI/UIImage+Alpha.h>
#import "MMSingleStackManager.h"

static UIImage* whiteThumb;
static UIImage* missingThumb;

@interface MMStackPropertiesView ()<UITextFieldDelegate>

@end

@implementation MMStackPropertiesView{
    NSString* stackUUID;
    UITextField* nameInput;
    CGAffineTransform page1Transform;

    UIImageView* page1Thumbnail;
    UIImageView* page2Thumbnail;
    UIImageView* page3Thumbnail;
}

-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)_stackUUID{
    if(self = [super initWithFrame:frame]){
        stackUUID = _stackUUID;
        
        UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.boxSize, self.boxSize)];
        contentView.backgroundColor = [UIColor whiteColor];
        [self.maskedScrollContainer addSubview:contentView];

        nameInput = [[UITextField alloc] initWithFrame:CGRectMake(60, 40, self.boxSize - 120, 50)];
        nameInput.font = [UIFont systemFontOfSize:26];
        nameInput.borderStyle = UITextBorderStyleRoundedRect;
        nameInput.textAlignment = NSTextAlignmentCenter;
        nameInput.textColor = [UIColor darkGrayColor];
        nameInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        nameInput.placeholder = @"Tap to set name";
        nameInput.returnKeyType = UIReturnKeyDone;
        nameInput.delegate = self;
        [contentView addSubview:nameInput];
        
        CGFloat stackIconHeight = 340;
        CGFloat thumbOffset = 10;
        CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
        CGFloat scale = stackIconHeight / CGRectGetHeight(screenBounds);
        CGRect thumbFrame = CGRectApplyAffineTransform(screenBounds, CGAffineTransformMakeScale(scale, scale));
        thumbFrame.origin.x += (CGRectGetWidth(contentView.bounds) - CGRectGetWidth(thumbFrame)) / 2;
        thumbFrame.origin.y = 110;
        CGRect pageThumbFrame = CGRectInset(thumbFrame, thumbOffset, thumbOffset);

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            CGRect bounds = thumbFrame;
            bounds.origin = CGPointZero;
            
            UIGraphicsBeginImageContext(bounds.size);
            [[UIColor whiteColor] setFill];
            UIRectFill(bounds);
            whiteThumb = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            whiteThumb = [whiteThumb transparentBorderImage:1];
            
            UIGraphicsBeginImageContext(bounds.size);
            
            [[UIColor darkGrayColor] setStroke];
            CGRect pathRect = pageThumbFrame;
            pathRect.origin = CGPointMake(thumbOffset, thumbOffset);
            UIBezierPath* pageOutline = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:10];
            pageOutline.lineWidth = 2;
            CGFloat dashPattern[] = {12,12}; //make your pattern here
            [pageOutline setLineDash:dashPattern count:2 phase:11];
            [pageOutline stroke];
            
            
            NSDictionary* attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:20], NSForegroundColorAttributeName : [UIColor darkGrayColor] };
            CGSize strSize = [@"Empty" sizeWithAttributes:attrs];
            CGRect strRect = CGRectZero;
            strRect.origin = CGPointMake((thumbFrame.size.width - strSize.width) / 2, (thumbFrame.size.height - strSize.height) / 2);
            strRect.size = strSize;
            [@"Empty" drawInRect:strRect withAttributes:attrs];
            
            missingThumb = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        
        page3Thumbnail = [[UIImageView alloc] initWithFrame:pageThumbFrame];
        page3Thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        page3Thumbnail.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
        page3Thumbnail.layer.shadowOffset = CGSizeZero;
        page3Thumbnail.layer.shadowRadius = 2;
        page3Thumbnail.layer.shadowOpacity = 1;
        [contentView addSubview:page3Thumbnail];
        
        page2Thumbnail = [[UIImageView alloc] initWithFrame:pageThumbFrame];
        page2Thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        page2Thumbnail.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
        page2Thumbnail.layer.shadowOffset = CGSizeZero;
        page2Thumbnail.layer.shadowRadius = 2;
        page2Thumbnail.layer.shadowOpacity = 1;
        [contentView addSubview:page2Thumbnail];
        
        page1Thumbnail = [[UIImageView alloc] initWithFrame:pageThumbFrame];
        page1Thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        page1Thumbnail.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
        page1Thumbnail.layer.shadowOffset = CGSizeZero;
        page1Thumbnail.layer.shadowRadius = 2;
        page1Thumbnail.layer.shadowOpacity = 1;
        [contentView addSubview:page1Thumbnail];
        
        CGFloat sign = rand() % 2 ? -1 : 1;
        page1Transform = CGAffineTransformMakeRotation(sign * (((rand() % 100) / 100.0 - 1.0) * .05 + .01));
        page1Thumbnail.transform = page1Transform;
        page2Thumbnail.transform = CGAffineTransformMakeRotation(sign * (((rand() % 100) / 100.0) * .07 + .03));
        page3Thumbnail.transform = CGAffineTransformMakeRotation(sign * (((rand() % 100) / 100.0 - 1.0) * .07 + .03));
        
        nameInput.text = [[MMAllStacksManager sharedInstance] nameOfStack:stackUUID];
        
        [self loadThumbs];
    }
    return self;
}

-(void) loadThumbs{
    NSArray* allPages = [[MMAllStacksManager sharedInstance] cachedPagesForStack:stackUUID];
    
    NSString* page1UUID = [allPages firstObject][@"uuid"];
    BOOL hasThumb = NO;
    
    UIImage* image = [MMSingleStackManager hasThumbail:&hasThumb forPage:page1UUID forStack:stackUUID];
    CGSize thumbSize = CGSizeApplyAffineTransform(page1Thumbnail.bounds.size, CGAffineTransformMakeScale([[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]));
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:thumbSize interpolationQuality:kCGInterpolationMedium];
    image = [image transparentBorderImage:2];
    if(image || hasThumb){
        page1Thumbnail.image = image ?: whiteThumb;
        page1Thumbnail.transform = page1Transform;
    }else{
        page1Thumbnail.transform = CGAffineTransformIdentity;
    }
    
    if([allPages count] > 1){
        NSString* page2UUID = [allPages objectAtIndex:1][@"uuid"];
        UIImage* image = [MMSingleStackManager hasThumbail:&hasThumb forPage:page2UUID forStack:stackUUID];
        image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:page1Thumbnail.bounds.size interpolationQuality:kCGInterpolationMedium];
        image = [image transparentBorderImage:2];
        page2Thumbnail.image = image ?: (hasThumb ? whiteThumb : nil);
    }else{
        page2Thumbnail.image = nil;
    }
    
    if([allPages count] > 2){
        NSString* page3UUID = [allPages objectAtIndex:2][@"uuid"];
        UIImage* image = [MMSingleStackManager hasThumbail:&hasThumb forPage:page3UUID forStack:stackUUID];
        image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:page1Thumbnail.bounds.size interpolationQuality:kCGInterpolationMedium];
        image = [image transparentBorderImage:2];
        page3Thumbnail.image = image ?: (hasThumb ? whiteThumb : nil);
    }else{
        page3Thumbnail.image = nil;
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[MMAllStacksManager sharedInstance] updateName:textField.text forStack:stackUUID];
}

@end

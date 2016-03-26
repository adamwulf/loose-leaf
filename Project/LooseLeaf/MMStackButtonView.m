//
//  MMStackButtonView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackButtonView.h"
#import "MMStackManager.h"
#import "MMStacksManager.h"
#import "MMTextButton.h"


static UIImage* whiteThumb;
static UIImage* missingThumb;

@implementation MMStackButtonView{
    NSString* stackUUID;
    UIImageView* pageThumbnail;
    UIButton* stackButton;
}

-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)_stackUUID{
    if(self = [super initWithFrame:frame]){

        [self clipsToBounds];
        
        stackUUID = _stackUUID;
        
        CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
        CGFloat scale = CGRectGetHeight(self.bounds) / CGRectGetHeight(screenBounds);
        CGRect thumbFrame = CGRectApplyAffineTransform(screenBounds, CGAffineTransformMakeScale(scale, scale));
        CGRect pageThumbFrame = CGRectInset(thumbFrame, 10, 10);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            CGRect bounds = thumbFrame;
            bounds.origin = CGPointZero;
            
            UIGraphicsBeginImageContext(bounds.size);
            [[UIColor whiteColor] setFill];
            UIRectFill(bounds);
            whiteThumb = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            
            UIGraphicsBeginImageContext(bounds.size);
            
            [[UIColor lightGrayColor] setStroke];
            UIBezierPath* pageOutline = [UIBezierPath bezierPathWithRoundedRect:pageThumbFrame cornerRadius:10];
            pageOutline.lineWidth = 2;
            CGFloat dashPattern[] = {12,12}; //make your pattern here
            [pageOutline setLineDash:dashPattern count:2 phase:11];
            [pageOutline stroke];
            
            
            NSDictionary* attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:20], NSForegroundColorAttributeName : [UIColor lightGrayColor] };
            CGSize strSize = [@"Empty" sizeWithAttributes:attrs];
            CGRect strRect = CGRectZero;
            strRect.origin = CGPointMake((thumbFrame.size.width - strSize.width) / 2, (thumbFrame.size.height - strSize.height) / 2);
            strRect.size = strSize;
            [@"Empty" drawInRect:strRect withAttributes:attrs];
            
            
            missingThumb = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
        });
        
        pageThumbnail = [[UIImageView alloc] initWithFrame:pageThumbFrame];
        pageThumbnail.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:pageThumbnail];
        
        stackButton = [[UIButton alloc] initWithFrame:self.bounds];
        [stackButton addTarget:self action:@selector(switchToStackAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stackButton];
    }
    return self;
}

-(void) loadThumb{
    
    NSDictionary* stackPageIDs = [MMStackManager loadFromDiskForStackUUID:stackUUID];
    NSString* pageUUID = [stackPageIDs[@"visiblePages"] firstObject][@"uuid"];

    NSString* stackPath = [[MMStacksManager sharedInstance] stackDirectoryPathForUUID:stackUUID];
    NSString* pagePath = [[stackPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:pageUUID];
    NSString* thumbPath = [pagePath stringByAppendingPathComponent:@"scrapped.thumb.png"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]){
        UIImage* thumb = [UIImage imageWithContentsOfFile:thumbPath];
        if(thumb){
            NSLog(@"have thumb: %@", thumbPath);
            pageThumbnail.image = thumb;
        }else{
            NSLog(@"should have thumb but don't");
            pageThumbnail.image = whiteThumb;
        }
    }else if([[NSFileManager defaultManager] fileExistsAtPath:pagePath]){
        NSLog(@"page is white");
        pageThumbnail.image = whiteThumb;
    }else{
        NSLog(@"no pages");
        pageThumbnail.image = missingThumb;
    }
}

-(void) switchToStackAction:(id)sender{
    [[self delegate] switchToStackAction:stackUUID];
}


@end

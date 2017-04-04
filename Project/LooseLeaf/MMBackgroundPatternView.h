//
//  MMBackgroundPatternView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/3/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMScrapViewState, MMScrapBackgroundView;

@interface MMBackgroundPatternView : UIView{
    CGSize originalSize;
    CGSize pageSize;
}

-(instancetype) init NS_UNAVAILABLE;
-(instancetype) initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
-(instancetype) initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(instancetype) initWithFrame:(CGRect)frame andProperties:(NSDictionary*)properties;

@property (nonatomic, readonly) CGPoint scale;

- (MMScrapBackgroundView*)stampBackgroundFor:(MMScrapViewState*)targetScrapState;

-(void) drawInContext:(CGContextRef)context forSize:(CGSize)size;

-(NSDictionary*) properties;

-(void) saveDefaultThumbToPath:(NSString*)path forSize:(CGSize)size;

@end

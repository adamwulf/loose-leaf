//
//  SLShadowedView.h
//  scratchpaper
//
//  Created by Adam Wulf on 7/5/12.
//
//

#import <UIKit/UIKit.h>

@interface SLShadowedView : UIView{
    UIView* contentView;
    
    // cache of the frame since it's computed by UIKit
    CGRect lastFrame;
}
@property (nonatomic, readonly) UIView* contentView;

+(CGRect) expandFrame:(CGRect)rect;
+(CGRect) contractFrame:(CGRect)rect;
+(CGRect) expandBounds:(CGRect)rect;
+(CGRect) contractBounds:(CGRect)rect;
@end

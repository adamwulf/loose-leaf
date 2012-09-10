//
//  PaintableImageView.h
//  PaintingSample
//
//  Created by Adam Wulf on 9/9/12.
//
//

#import <UIKit/UIKit.h>
#import "PaintTouchViewDelegate.h"
#import "PaintView.h"

@interface PaintableImageView : UIImageView<PaintTouchViewDelegate>{
    PaintView* paint;
    CGPoint panCoord;
}

@property (nonatomic, readonly) CGRect rotationlessFrame;

@end

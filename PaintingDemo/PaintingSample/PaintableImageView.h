//
//  PaintableImageView.h
//  PaintingSample
//
//  Created by Adam Wulf on 9/9/12.
//
//

#import <UIKit/UIKit.h>
#import "PaintTouchViewDelegate.h"
#import "PaintableViewDelegate.h"
#import "PaintView.h"

@interface PaintableImageView : UIImageView<PaintTouchViewDelegate,PaintableViewDelegate>{
    PaintView* paint;
    CGPoint panCoord;
    NSObject<PaintableViewDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<PaintableViewDelegate>* delegate;
@property (nonatomic, readonly) CGRect rotationlessFrame;
@property (nonatomic, retain) UIBezierPath* clipPath;

@end

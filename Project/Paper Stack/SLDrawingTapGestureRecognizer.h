//
//  SLDrawingTapGestureRecognizer.h
//  PaintingSample
//
//  Created by Adam Wulf on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLDrawingTapGestureRecognizer : UITapGestureRecognizer{
    CGFloat fingerWidth;
}

@property (nonatomic, readonly) CGFloat fingerWidth;

@end

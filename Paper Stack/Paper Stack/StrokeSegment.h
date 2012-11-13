//
//  StrokeSegment.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/10/12.
//
//

#import <Foundation/Foundation.h>

@interface StrokeSegment : NSObject<NSCoding>{
    CGFloat fingerWidth;
    CGRect rectToDisplay;
    UIBezierPath* path;
    BOOL shouldFillInsteadOfStroke;
}
@property (nonatomic, assign) CGFloat fingerWidth;
@property (nonatomic, assign) CGRect rectToDisplay;
@property (nonatomic, retain) UIBezierPath* path;
@property (nonatomic, assign) BOOL shouldFillInsteadOfStroke;

+(StrokeSegment*) strokeWithFingerWidth:(CGFloat)_fingerWidth andRect:(CGRect)_rectToDisplay andPath:(UIBezierPath*)_path;

+(StrokeSegment*) strokeWithFingerWidth:(CGFloat)_fingerWidth andRect:(CGRect)_rectToDisplay andPath:(UIBezierPath*)_path andFill:(BOOL)_fill;


@end

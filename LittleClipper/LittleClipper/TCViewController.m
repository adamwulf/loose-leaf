//
//  TCViewController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "TCViewController.h"
#import <TouchShape/TouchShape.h>
#import <ClippingBezier/ClippingBezier.h>
#import <PerformanceBezier/PerformanceBezier.h>
#import "SYSaveMessageView.h"
#import "SYTableBase.h"
#import "SYShape+Bezier.h"

@interface TCViewController () 

@end

#define kMinTolerance 0.0000001

@implementation TCViewController{
    TCShapeController* shapeController;
    int bugsReportedCount;
    int scissorsDrawnCount;
}

#pragma mark - Lifecycle Methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self resetData];
    
}


- (void) viewDidUnload
{
    [super viewDidUnload];
    
    paintView = nil;
    
    vectorView = nil;
    
}

#pragma mark - Calculate Shapes

-(void) resetData{
    shapeController = [[TCShapeController alloc] init];
}

- (IBAction) rebuildShape:(id)sender
{
    continuityLabel.text = [NSString stringWithFormat:@"%4.2f",[continuitySlider value]];
//    float val = toleranceSlider.value;
//    float tol = kMinTolerance;
//    val = val * kMinTolerance;
    toleranceLabel.text = [NSString stringWithFormat:@"%4.7f",[toleranceSlider value]*kMinTolerance];
    
    [vectorView.shapeList removeLastObject];
    [self getFigurePainted];
    
}




-(BOOL)checkLineIntersection:(CGPoint)p1 :(CGPoint)p2 :(CGPoint)p3 :(CGPoint)p4
{
    CGFloat denominator = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y);
    CGFloat ua = (p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x);
    CGFloat ub = (p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x);
    if (denominator < 0) {
        ua = -ua; ub = -ub; denominator = -denominator;
    }
    return (ua > 0.0 && ua <= denominator && ub > 0.0 && ub <= denominator);
}


-(BOOL) shapeIsSelfIntersecting:(SYShape*)shape{

    __block BOOL doesIntersect = NO;
    
    __block CGPoint ele1Start = CGPointZero;
    [shape.bezierPath iteratePathWithBlock:^(CGPathElement ele1, NSUInteger idx){
        CGPoint ele1End;
        if(ele1.type == kCGPathElementMoveToPoint){
            ele1End = ele1.points[0];
        }else if(ele1.type == kCGPathElementAddCurveToPoint){
            ele1End = ele1.points[2];
        }else if(ele1.type == kCGPathElementAddLineToPoint){
            ele1End = ele1.points[0];
        }else if(ele1.type == kCGPathElementAddQuadCurveToPoint){
            ele1End = ele1.points[1];
        }else if(ele1.type == kCGPathElementCloseSubpath){
            ele1End = shape.bezierPath.firstPoint;
        }else{
            @throw [NSException exceptionWithName:@"BezierException" reason:[NSString stringWithFormat:@"Unknown element type: %d", ele1.type] userInfo:nil];
        }
        
        
        if(ele1.type != kCGPathElementMoveToPoint){
            __block CGPoint ele2Start = CGPointZero;
            [shape.bezierPath iteratePathWithBlock:^(CGPathElement ele2, NSUInteger idx){
                CGPoint ele2End;
                if(ele2.type == kCGPathElementMoveToPoint){
                    ele2End = ele2.points[0];
                }else if(ele2.type == kCGPathElementAddCurveToPoint){
                    ele2End = ele2.points[2];
                }else if(ele2.type == kCGPathElementAddLineToPoint){
                    ele2End = ele2.points[0];
                }else if(ele2.type == kCGPathElementAddQuadCurveToPoint){
                    ele2End = ele2.points[1];
                }else if(ele2.type == kCGPathElementCloseSubpath){
                    ele2End = shape.bezierPath.firstPoint;
                }
                
                
                if(ele2.type != kCGPathElementMoveToPoint){
                    CGPoint intersection = [UIBezierPath intersects2D:ele1Start to:ele1End andLine:ele2Start to:ele2End];
                    
                    if(!CGPointEqualToPoint(intersection, CGPointNotFound) &&
                       (roundf(intersection.x*100) != roundf(ele1Start.x*100) ||
                        roundf(intersection.y*100) != roundf(ele1Start.y*100)) &&
                       (roundf(intersection.x*100) != roundf(ele1End.x*100) ||
                        roundf(intersection.y*100) != roundf(ele1End.y*100)) &&
                       (roundf(intersection.x*100) != roundf(ele2Start.x*100) ||
                        roundf(intersection.y*100) != roundf(ele2Start.y*100)) &&
                       (roundf(intersection.x*100) != roundf(ele2End.x*100) ||
                        roundf(intersection.y*100) != roundf(ele2End.y*100))){
                           
                           doesIntersect = YES;
                       }
                }
                ele2Start = ele2End;
            }];
        }
        
        ele1Start = ele1End;
    }];
    
    return doesIntersect;
}

- (SYShape*) getFigurePainted
{
    SYShape* possibleShape = [shapeController getFigurePaintedWithTolerance:[toleranceSlider value]*kMinTolerance andContinuity:[continuitySlider value] forceOpen:(shapeVsScissorChooser.selectedSegmentIndex != 0)];
    if(possibleShape){
//        @throw [NSException exceptionWithName:@"Test Target Exception" reason:@"testing crashlytics" userInfo:nil];
        [filledShapeView clear];
        
        if([self shapeIsSelfIntersecting:possibleShape]){
            if(shapeVsScissorChooser.selectedSegmentIndex == 0){
                // clear the shape
                [vectorView clear:nil];
            }else{
                NSArray* shapes = [NSArray arrayWithArray:vectorView.shapeList];
                [vectorView clear:nil];
                if([shapes count]){
                    // add in just the shape, but erase the scissor
                    SYShape* shape = [shapes firstObject];
                    [vectorView addShape:shape];
                }
            }
            return nil;
        }
        
        if(shapeVsScissorChooser.selectedSegmentIndex == 0){
            // shape
            [vectorView clear:nil];
            // must be closed
            if(possibleShape.isClosedCurve){
                [vectorView addShape:possibleShape];
                [vectorView setNeedsDisplay];
            }
        }else{
            
            NSArray* shapes = [NSArray arrayWithArray:vectorView.shapeList];
            [vectorView clear:nil];
            if([shapes count]){
                SYShape* shape = [shapes firstObject];

                [vectorView addShape:shape];
                // scissor
                [vectorView addShape:possibleShape];
                [vectorView setNeedsDisplay];
                
                
                @try{
                    UIBezierPath* shapePath = shape.bezierPath;
                    UIBezierPath* scissorPath = possibleShape.bezierPath;
                    
                    NSArray* foundShapes = [shapePath uniqueShapesCreatedFromSlicingWithUnclosedPath:scissorPath];
                    
                    BOOL allAreClosed = YES;
                    for(DKUIBezierPathShape* cutShapePath in foundShapes){
                        [filledShapeView addShapePath:cutShapePath.fullPath];
                        if(!cutShapePath.isClosed){
                            // force saving a bug
                            allAreClosed = NO;
                        }
                    }
                    scissorsDrawnCount++;
                }@catch (id exc) {
                    NSLog(@"Error finding shapes: %@", exc);
                }
            }
        }
    }
    return possibleShape;
}

-(IBAction) redrawFilledShape{
    [filledShapeView setNeedsDisplay];
}

-(IBAction) clearShape:(id)sender{
    [filledShapeView clear];
}

#pragma mark - Cloud Points Methods

- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
{
    [shapeController addPoint:pointA andPoint:pointB];
}


- (void) addLastPoint:(CGPoint) lastPoint
{
    [shapeController addLastPoint:lastPoint];
    
    // Analyze a recognize the figure
    [self getFigurePainted];
    
}

@end

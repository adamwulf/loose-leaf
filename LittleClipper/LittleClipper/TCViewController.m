//
//  TCViewController.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import "TCViewController.h"
#import <TouchShape/TouchShape.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
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
    
}// viewDidLoad


- (void) viewDidUnload
{
    [super viewDidUnload];
    
    paintView = nil;
    
    vectorView = nil;
    
}// viewDidUnload



- (IBAction) saveCase:(id)sender
{
    
    UIGraphicsBeginImageContext(vectorView.bounds.size);
    [vectorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    [filledShapeView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* image1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(image1);

    
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    [dateFormater setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
    NSString *convertedDateString = [dateFormater stringFromDate:[NSDate date]];

    
    
    NSString* textForEmail = @"Shapes in view:\n\n";
    
    NSArray* subArray = [vectorView.shapeList subarrayWithRange:NSMakeRange(0, MIN([vectorView.shapeList count], 2))];
    
    for(SYShape* shape in subArray){
        textForEmail = [textForEmail stringByAppendingFormat:@"shape:\n%@\n\n\n", shape.bezierPath];
    }
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:[NSArray arrayWithObject:@"adam.wulf@gmail.com"]];
    [controller setSubject:[NSString stringWithFormat:@"Shape Clipping Test Case %@", convertedDateString]];
    [controller setMessageBody:textForEmail isHTML:NO];
    [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"screenshot.png"];
    if(controller) [self presentViewController:controller animated:YES completion:nil];
}// saveCase:



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
    
}// rebuildShape




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
    [shape.bezierPath iteratePathWithBlock:^(CGPathElement ele1){
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
        }
        
        
        if(ele1.type != kCGPathElementMoveToPoint){
            __block CGPoint ele2Start = CGPointZero;
            [shape.bezierPath iteratePathWithBlock:^(CGPathElement ele2){
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
                    CGPoint intersection = Intersection3(ele1Start, ele1End, ele2Start, ele2End);
                    
                    if(!CGPointEqualToPoint(intersection, CGNotFoundPoint) &&
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
                [self drawRecentlyReducedKeyPoints];
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
                [self drawRecentlyReducedKeyPoints];
                [vectorView addShape:possibleShape];
                [vectorView setNeedsDisplay];
                
                
                @try{
                    UIBezierPath* shapePath = shape.bezierPath;
                    UIBezierPath* scissorPath = possibleShape.bezierPath;
                    
                    NSArray* foundShapes = [shapePath uniqueShapesCreatedFromSlicingWithUnclosedPath:scissorPath];
                    
//                    DebugLog(@"Cutting Shape: %@", shapePath);
//                    DebugLog(@"With Scissor: %@", scissorPath);
//                    
//                    DebugLog(@"found %d shapes", [foundShapes count]);
                    
                    BOOL allAreClosed = YES;
                    for(DKUIBezierPathShape* cutShapePath in foundShapes){
                        [filledShapeView addShapePath:cutShapePath.fullPath];
                        if(!cutShapePath.isClosed){
                            // force saving a bug
                            allAreClosed = NO;
                        }
                    }
                    if(!allAreClosed){
                        [self saveCase:nil];
                    }
                    scissorsDrawnCount++;
                    [self updateBugReport];
                }@catch (id exc) {
                    [self saveCase:nil];
                }
            }
        }
    }
    return possibleShape;
}

-(IBAction) redrawFilledShape{
    [filledShapeView setNeedsDisplay];
}


- (void) drawRecentlyReducedKeyPoints{
    return;
    NSDictionary* output = [shapeController recentlyReducedKeyPoints];
    // --------------------------------------------------------------------------
    
    // DEBUG DRAW
    SYShape *keyPointShape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*kMinTolerance];
    for (NSValue *pointValue in [output objectForKey:@"listPoints"])
        [keyPointShape addPoint:[pointValue CGPointValue]];
    [vectorView addDebugShape:keyPointShape];
    
    // DEBUG DRAW
    SYShape *reducePointKeyArrayShape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*kMinTolerance];
    for (NSValue *pointValue in [output objectForKey:@"reducePointKeyArray"])
        [reducePointKeyArrayShape addKeyPoint:[pointValue CGPointValue]];
    [vectorView addDebugShape:reducePointKeyArrayShape];
}

#pragma mark - Cloud Points Methods

- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
{
    [shapeController addPoint:pointA andPoint:pointB];
}// addPoint:andPoint:


- (void) addLastPoint:(CGPoint) lastPoint
{
    [shapeController addLastPoint:lastPoint];
    
    // Analyze a recognize the figure
    [self getFigurePainted];
    
}// addLastPoint:

#pragma mark - Bug Reports

-(void) updateBugReport{
    successRateLabel.text = [NSString stringWithFormat:@"%d / %d", bugsReportedCount, scissorsDrawnCount];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(result == MFMailComposeResultSaved ||
       result == MFMailComposeResultSent){
        bugsReportedCount++;
        [self updateBugReport];
    }
}
@end

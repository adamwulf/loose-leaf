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


@implementation TCViewController{
    TCShapeController* shapeController;
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
    
    NSString* textForEmail = @"Shapes in view:\n\n";
    
    NSArray* subArray = [vectorView.shapeList subarrayWithRange:NSMakeRange(0, MIN([vectorView.shapeList count], 2))];
    
    for(SYShape* shape in subArray){
        textForEmail = [textForEmail stringByAppendingFormat:@"shape:\n%@\n\n\n", shape.bezierPath];
    }
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:[NSArray arrayWithObject:@"adam.wulf@gmail.com"]];
    [controller setSubject:@"Shape Clipping Test Case"];
    [controller setMessageBody:textForEmail isHTML:NO];
    [self presentViewController:controller animated:YES completion:nil];
}// saveCase:



#pragma mark - Calculate Shapes

-(void) resetData{
    shapeController = [[TCShapeController alloc] init];
}

- (IBAction) rebuildShape:(id)sender
{
    continuityLabel.text = [NSString stringWithFormat:@"%4.2f",[continuitySlider value]];
    toleranceLabel.text = [NSString stringWithFormat:@"%4.6f",[toleranceSlider value]*0.0001];
    
    [vectorView.shapeList removeLastObject];
    [self getFigurePainted];
    
}// rebuildShape


- (SYShape*) getFigurePainted
{
    SYShape* possibleShape = [shapeController getFigurePaintedWithTolerance:[toleranceSlider value]*0.0001 andContinuity:[continuitySlider value]];
    [filledShapeView clear];
    if(possibleShape){
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
                    
                    
                    NSArray* subShapePaths = [shapePath subshapesCreatedFromSlicingWithUnclosedPath:scissorPath];
                    NSArray* foundShapes = [subShapePaths firstObject];
                    
                    NSLog(@"Cutting Shape: %@", shapePath);
                    NSLog(@"With Scissor: %@", scissorPath);
                    
                    NSLog(@"found %d shapes", [foundShapes count]);
                    
                    for(DKUIBezierPathShape* cutShapePath in foundShapes){
                        [filledShapeView addShapePath:cutShapePath.fullPath];
                    }
                }@catch (id exc) {
                    [self saveCase:nil];
                }
            }
        }
    }
    return possibleShape;
}


- (void) drawRecentlyReducedKeyPoints{
    return;
    NSDictionary* output = [shapeController recentlyReducedKeyPoints];
    // --------------------------------------------------------------------------
    
    // DEBUG DRAW
    SYShape *keyPointShape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
    for (NSValue *pointValue in [output objectForKey:@"listPoints"])
        [keyPointShape addPoint:[pointValue CGPointValue]];
    [vectorView addDebugShape:keyPointShape];
    
    // DEBUG DRAW
    SYShape *reducePointKeyArrayShape = [[SYShape alloc]initWithBezierTolerance:[toleranceSlider value]*0.0001];
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


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

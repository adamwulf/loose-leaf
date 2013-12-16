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
    
    // Hide table
    [tableBase setAlpha:.0];
    [tableBase setHidden:YES];
    
    [self resetData];
    
}// viewDidLoad


- (void) viewDidUnload
{
    [super viewDidUnload];
    
    paintView = nil;
    
    vectorView = nil;
    
}// viewDidUnload


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    
}// shouldAutorotateToInterfaceOrientation:


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    [selectCaseNameView setAlpha:.0];
    [vectorView setNeedsDisplay];
    
}// willRotateToInterfaceOrientation:duration:


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    // Set message view position
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        [selectCaseNameView setFrame:CGRectMake(240.0, 382.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    else
        [selectCaseNameView setFrame:CGRectMake(369.0, 217.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    
    [selectCaseNameView setNeedsDisplay];
    
    [UIView animateWithDuration:0.3 animations:^{
        [selectCaseNameView setAlpha:1.0];
    }];
    
}// didRotateFromInterfaceOrientation:



#pragma mark - Unit Test Methods

- (IBAction) selectName:(id)sender
{
    if (![shapeController hasPointData]) {
        // Avisa del error obtenido
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Draw Something"
                                                        message:@"You must draw a valid shape before"
                                                       delegate:self
                                              cancelButtonTitle:@"Accept"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Set message view position
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        [selectCaseNameView setFrame:CGRectMake(240.0, 382.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    else
        [selectCaseNameView setFrame:CGRectMake(369.0, 217.0, selectCaseNameView.frame.size.width, selectCaseNameView.frame.size.height)];
    
    
    [nameTextField becomeFirstResponder];
    [selectCaseNameView setAlpha:.0];
    [selectCaseNameView setHidden:NO];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:1.0];
    }];
    
}// selectName:


- (IBAction) saveCase:(id)sender
{
    // If the user doesn't write name
    if ([[nameTextField text]length] == 0 || ![shapeController hasPointData])
        return;
    
    // Store new case
    [nameTextField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:.0];
    }completion:^(BOOL finished){
        [selectCaseNameView setHidden:YES];
        nameTextField.text = @"";
    }];
    
    // Send notification to Test controller
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:paintView.allPoints, @"allPoints", nameTextField.text, @"name", nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"saveListPoints" object:self userInfo:d];
        
}// saveCase:


- (IBAction) cancelCase:(id)sender
{
    [nameTextField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [selectCaseNameView setAlpha:.0];
    }completion:^(BOOL finished){
        [selectCaseNameView setHidden:YES];
    }];
    
}// cancelCase


#pragma mark - Unit Test Operations

- (void) importCase:(NSArray *) allPoints
{
    // Clear Paint
    [paintView clearPaint];
    
    // Init Data
    [self resetData];
    
    for (NSUInteger i = 1 ; i < [allPoints count]-1 ; i++) {
        // Add these new points
        CGPoint touchPreviousLocation = [[allPoints objectAtIndex:i-1]CGPointValue];
        CGPoint touchLocation = [[allPoints objectAtIndex:i]CGPointValue];
        [shapeController addPoint:touchPreviousLocation andPoint:touchLocation];
    }
    
    CGPoint touchLocation = [[allPoints lastObject]CGPointValue];
    [shapeController addLastPoint:touchLocation];
    
    // Analyze a recognize the figure
    [self getFigurePainted];
    
}// importCase


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
                
                UIBezierPath* shapePath = shape.bezierPath;
                UIBezierPath* scissorPath = possibleShape.bezierPath;
                
                
                NSArray* subShapePaths = [shapePath subshapesCreatedFromSlicingWithUnclosedPath:scissorPath];
                NSArray* foundShapes = [subShapePaths firstObject];

                NSLog(@"found %d shapes", [foundShapes count]);
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

@end

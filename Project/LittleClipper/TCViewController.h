//
//  TCViewController.h
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 28/05/12.
//  Copyright (c) 2012 Sylion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <TouchShape/TouchShape.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import "SYUnitTestController.h"
#import "MMFilledShapeView.h"

@class SYSaveMessageView;
@class SYPaintView;
@class SYVectorView;
@class SYTableBase;

@interface TCViewController : UIViewController <SYUnitTestDelegate,SYPaintViewDelegate> {
    
    IBOutlet UISegmentedControl* shapeVsScissorChooser;
    IBOutlet MMFilledShapeView* filledShapeView;
    
    // Views
    IBOutlet SYPaintView *paintView;        // Get the points from the finger touch
    IBOutlet SYVectorView *vectorView;      // Will draw the final shape

    // Test
    IBOutlet SYTableBase *tableBase;
    IBOutlet SYSaveMessageView *selectCaseNameView;
    IBOutlet UITextField *nameTextField;
    
    IBOutlet UISlider *continuitySlider;
    IBOutlet UISlider *toleranceSlider;
    IBOutlet UILabel *continuityLabel;
    IBOutlet UILabel *toleranceLabel;
    
}

// Test Methods
- (IBAction) selectName:(id)sender;
- (IBAction) saveCase:(id)sender;
- (IBAction) cancelCase:(id)sender;
- (void) importCase:(NSArray *) allPoints;

- (SYShape*) getFigurePainted;

// SYPaintViewDelegate
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;
-(void) resetData;

@end

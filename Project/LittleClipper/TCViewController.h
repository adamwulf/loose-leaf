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
#import "MMFilledShapeView.h"
#import <MessageUI/MFMailComposeViewController.h>

@class SYSaveMessageView;
@class SYPaintView;
@class SYVectorView;
@class SYTableBase;

@interface TCViewController : UIViewController <MFMailComposeViewControllerDelegate,SYPaintViewDelegate> {
    
    IBOutlet UISegmentedControl* shapeVsScissorChooser;
    IBOutlet MMFilledShapeView* filledShapeView;
    
    // Views
    IBOutlet SYPaintView *paintView;        // Get the points from the finger touch
    IBOutlet SYVectorView *vectorView;      // Will draw the final shape
    
    IBOutlet UISlider *continuitySlider;
    IBOutlet UISlider *toleranceSlider;
    IBOutlet UILabel *continuityLabel;
    IBOutlet UILabel *toleranceLabel;
    
    IBOutlet UILabel *successRateLabel;
    
}

// Test Methods
- (IBAction) saveCase:(id)sender;

- (SYShape*) getFigurePainted;

// SYPaintViewDelegate
- (void) addPoint:(CGPoint) pointA andPoint:(CGPoint) pointB;
- (void) addLastPoint:(CGPoint) lastPoint;
-(void) resetData;

@end

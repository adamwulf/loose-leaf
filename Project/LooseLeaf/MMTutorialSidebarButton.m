//
//  MMTutorialSidebarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialSidebarButton.h"
#import "MMTutorialManager.h"
#import "Constants.h"

@implementation MMTutorialSidebarButton{
    NSArray*(^tutorialListFunc)();
}

-(id) initWithFrame:(CGRect)frame andTutorialList:(NSArray*(^)())_tutorialListFunc{
    if(self = [super initWithFrame:frame andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:24] andLetter:@"?" andXOffset:0 andYOffset:0]){
        self.inverted = YES;
        tutorialListFunc = _tutorialListFunc;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tutorialStepFinished:) name:kTutorialStepCompleteNotification object:nil];
        
    }
   return self;
}

-(NSArray*) tutorialList{
    return tutorialListFunc();
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

-(void) tutorialStepFinished:(NSNotification*)note{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}


#pragma mark - Draw Rect

-(void) drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    NSInteger numPendingTutorials = [[MMTutorialManager sharedInstance] numberOfPendingTutorials:tutorialListFunc()];
    
    if(numPendingTutorials){
        UIColor* darkerGreyBorder = [self borderColor];
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // draw red circle of how many tutorials the user has left
        CGRect drawableFrame = [self drawableFrame];
        CGFloat sizeOfCircle = drawableFrame.size.width / 2;
        sizeOfCircle = MIN(24, MAX(sizeOfCircle, 20));
        CGRect circleFrame = CGRectMake(drawableFrame.size.width + drawableFrame.origin.x - sizeOfCircle, drawableFrame.origin.y, sizeOfCircle, sizeOfCircle);
        circleFrame.origin.x += circleFrame.size.width / 6;
        circleFrame.origin.y -= circleFrame.size.width / 6;
        
        UIBezierPath* redCircle = [UIBezierPath bezierPathWithOvalInRect:circleFrame];
        redCircle.lineWidth = 1;
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [redCircle fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        [[UIColor redColor] setFill];
        [redCircle fill];
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setStroke];
        [redCircle stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        [darkerGreyBorder setStroke];
        [redCircle stroke];
        
        
        // draw and center text of the number
        NSString* numberOfTutorials = [NSString stringWithFormat:@"%d", (int) numPendingTutorials];
        
        NSDictionary* textAttrs = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSFontAttributeName : [UIFont systemFontOfSize:ceilf(sizeOfCircle * 2 / 3)]};
        
        CGSize renderedSize = [numberOfTutorials sizeWithAttributes:textAttrs];
        
        CGFloat numYOffset = (circleFrame.size.height - renderedSize.height ) / 2;
        CGFloat numXOffset = (circleFrame.size.width - renderedSize.width ) / 2;
        
        circleFrame.origin.x += numXOffset;
        circleFrame.origin.y += numYOffset;
        
        [numberOfTutorials drawAtPoint:circleFrame.origin withAttributes:textAttrs];
    }
}

@end

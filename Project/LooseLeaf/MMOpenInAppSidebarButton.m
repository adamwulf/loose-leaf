//
//  MMOpenInAppSidebarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOpenInAppSidebarButton.h"
#import "MMShareManager.h"
#import "Constants.h"

@implementation MMOpenInAppSidebarButton{
    BOOL needsUpdate;
}

@synthesize indexPath;

- (id)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath*)_indexPath{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.indexPath = _indexPath;
    }
    return self;
}

-(void) setIndexPath:(NSIndexPath *)_indexPath{
    if(!indexPath ||
       indexPath.row != _indexPath.row ||
       indexPath.section != _indexPath.section){
        indexPath = _indexPath;
        [self performSelector:@selector(tryDisplayAgain) withObject:nil afterDelay:.1];
        [self performSelector:@selector(tryDisplayAgain) withObject:nil afterDelay:.3];
        [self performSelector:@selector(tryDisplayAgain) withObject:nil afterDelay:1];
    }
    if(needsUpdate){
        [self setNeedsDisplay];
    }
}

-(void) tryDisplayAgain{
    if(needsUpdate){
        [self setNeedsDisplay];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    
    //// Oval Drawing
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    UIView* view = [[MMShareManager sharedInstance] viewForIndexPath:self.indexPath forceGet:NO];
    
    if(!view){
        needsUpdate = YES;
    }else{
        needsUpdate = NO;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [ovalPath addClip];
    
    CGRect viewFr = view.bounds;
    CGFloat ratio = view.bounds.size.height / view.bounds.size.width;
    CGFloat buffer = 2;
    viewFr.origin.x = buffer;
    viewFr.origin.y = buffer + 3;
    viewFr.size.width = self.bounds.size.width - 2*buffer;
    viewFr.size.height = ratio * (self.bounds.size.width - 2*buffer);
    
    
    [view drawViewHierarchyInRect:viewFr afterScreenUpdates:NO];
    CGContextRestoreGState(context);
    
//    [[NSString stringWithFormat:@"%d:%d", indexPath.section, indexPath.row] drawAtPoint:CGPointMake(20, 20) withAttributes:nil];
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}



#pragma mark - Redirect Touches

// the goal of this method is to direct the touch to
// the activity cell for the app we want to open

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* viewFromSuper = [super hitTest:point withEvent:event];
    if(viewFromSuper == self){
        UIView* cell = [[MMShareManager sharedInstance] viewForIndexPath:self.indexPath forceGet:YES];
        if(cell){
            [MMShareManager setShareTargetView:cell];
            
            for(NSObject* obj in self.allTargets){
                NSArray* actions = [self actionsForTarget:obj forControlEvent:UIControlEventTouchUpInside];
                for(NSString* action in actions){
                    [obj performSelector:NSSelectorFromString(action) withObject:event];
                }
            }
            return cell;
        }
    }

    return viewFromSuper;
}
//
//-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    NSArray* allCollectionViews = [[MMShareManager sharedInstance] allFoundCollectionViews];
//    for(UICollectionView* cv in allCollectionViews){
//        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
//        if(numberOfItems > 1){
//            return YES;
//        }
//    }
//    return NO;
//}



@end

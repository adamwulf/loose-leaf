//
//  MMScapBubbleContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapSidebarContainerView.h"
#import "MMScrapBubbleButton.h"
#import "NSThread+BlockAdditions.h"
#import "MMScrapSidebarContentView.h"
#import "MMScrapsOnPaperState.h"
#import "MMImmutableScrapsOnPaperState.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "NSFileManager+DirectoryOptimizations.h"

#define kMaxScrapsInBezel 6

@interface MMSidebarButtonTapGestureRecognizer : UITapGestureRecognizer

@end

@implementation MMSidebarButtonTapGestureRecognizer

-(BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

@end



@implementation MMScrapSidebarContainerView{
    CGFloat lastRotationReading;
    CGFloat targetAlpha;
    NSMutableOrderedSet* scrapsHeldInBezel;
    NSMutableDictionary* bubbleForScrap;
    MMCountBubbleButton* countButton;
    MMScrapSidebarContentView* contentView;
    MMScrapsOnPaperState* scrapState;
    NSString* scrapIDsPath;
    
    NSMutableDictionary* rotationAdjustments;
}

@synthesize bubbleDelegate;
@synthesize countButton;

-(id) initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton *)_countButton{
    if(self = [super initWithFrame:frame forButton:_countButton animateFromLeft:NO]){
        targetAlpha = 1;
        scrapsHeldInBezel = [NSMutableOrderedSet orderedSet];
        bubbleForScrap = [NSMutableDictionary dictionary];
        
        contentView = [[MMScrapSidebarContentView alloc] initWithFrame:[sidebarContentView contentBounds]];
        contentView.delegate = self;
        [sidebarContentView addSubview:contentView];

        countButton = _countButton;
        [countButton addTarget:self action:@selector(countButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        
        NSDictionary* loadedRotationValues = [NSDictionary dictionaryWithContentsOfFile:[MMScrapSidebarContainerView pathToPlist]];
        rotationAdjustments = [NSMutableDictionary dictionary];
        if(loadedRotationValues){
            [rotationAdjustments addEntriesFromDictionary:loadedRotationValues];
        }

        scrapState = [[MMScrapsOnPaperState alloc] initWithScrapIDsPath:self.scrapIDsPath];
        scrapState.delegate = self;
        [scrapState loadStateAsynchronously:YES andMakeEditable:NO];
    }
    return self;
}


#pragma mark - Helper Methods

-(NSString*) scrapIDsPath{
    if(!scrapIDsPath){
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* pagesPath = [documentsPath stringByAppendingPathComponent:@"Bezel"];
        [NSFileManager ensureDirectoryExistsAtPath:pagesPath];
        scrapIDsPath = [[pagesPath stringByAppendingPathComponent:@"scrapIDs"] stringByAppendingPathExtension:@"plist"];
    }
    return scrapIDsPath;
}

-(CGPoint) centerForBubbleAtIndex:(NSInteger)index{
    CGFloat rightBezelSide = self.bounds.size.width - 100;
    // midpoint calculates for 6 buttons
    CGFloat midPointY = (self.bounds.size.height - 6*80) / 2;
    CGPoint ret = CGPointMake(rightBezelSide + 40, midPointY + 40);
    ret.y += 80 * index;
    return ret;
}

-(CGFloat) alpha{
    return targetAlpha;
}

-(void) setAlpha:(CGFloat)alpha{
    targetAlpha = alpha;
    if([scrapsHeldInBezel count] > kMaxScrapsInBezel){
        countButton.alpha = targetAlpha;
    }else{
        countButton.alpha = 0;
        for(UIView* subview in self.subviews){
            if([subview isKindOfClass:[MMScrapBubbleButton class]]){
                subview.alpha = targetAlpha;
            }
        }
    }
    if(!targetAlpha){
        [self sidebarCloseButtonWasTapped];
    }
}


#pragma mark - Scrap Animations

-(void) addScrapToBezelSidebar:(MMScrapView *)scrap animated:(BOOL)animated{
    
    // make sure we've saved its current state
    if(animated){
        // only save when it's animated. non-animated is loading
        // from disk at start up
        [scrap saveToDisk];
    }
    
    [scrapsHeldInBezel insertObject:scrap atIndex:0];
    
    // exit the scrap to the bezel!
    CGPoint center = [self centerForBubbleAtIndex:0];
    
    // prep the animation by creating the new bubble for the scrap
    // and initializing it's probable location (may change if count > 6)
    // and set it's alpha/rotation/scale to prepare for the animation
    MMScrapBubbleButton* bubble = [[MMScrapBubbleButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    bubble.center = center;
    //
    // iOS7 changes how buttons can be tapped during a gesture (i think).
    // so adding our gesture recognizer explicitly, and disallowing it to
    // be prevented ensures that buttons can be tapped while other gestures
    // are in flight.
//    [bubble addTarget:self action:@selector(bubbleTapped:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer* tappy = [[MMSidebarButtonTapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleTapped:)];
    [bubble addGestureRecognizer:tappy];
    bubble.originalScrapScale = scrap.scale;
    [self insertSubview:bubble atIndex:0];
    [self insertSubview:scrap aboveSubview:bubble];
    // keep the scrap in the bezel container during the animation, then
    // push it into the bubble
    bubble.alpha = 0;
    bubble.rotation = lastRotationReading;
    bubble.scale = .9;
    [bubbleForScrap setObject:bubble forKey:scrap.uuid];
    
    
    //
    // unload the scrap state, so that it shows the
    // image preview instead of an editable state
    [scrap unloadState];

    
    if(animated){
        CGFloat animationDuration = 0.5;
        
        if([scrapsHeldInBezel count] <= kMaxScrapsInBezel){
            // allow adding to 6 in the sidebar, otherwise
            // we need to pull them all into 1 button w/
            // a menu
            
            [UIView animateWithDuration:animationDuration * .51 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                // animate the scrap into position
                bubble.alpha = 1;
                scrap.transform = CGAffineTransformConcat([MMScrapBubbleButton idealTransformForScrap:scrap], CGAffineTransformMakeScale(bubble.scale, bubble.scale));
                scrap.center = bubble.center;
                for(MMScrapBubbleButton* otherBubble in self.subviews){
                    if(otherBubble != bubble){
                        if([otherBubble isKindOfClass:[MMScrapBubbleButton class]]){
                            int index = [scrapsHeldInBezel indexOfObject:otherBubble.scrap];
                            otherBubble.center = [self centerForBubbleAtIndex:index];
                        }
                    }
                }

            } completion:^(BOOL finished){
                // add it to the bubble and bounce
                bubble.scrap = scrap;
                [rotationAdjustments setObject:@(bubble.rotationAdjustment) forKey:scrap.uuid];
                [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    // scrap "hits" the bubble and pushes it down a bit
                    bubble.scale = .8;
                    bubble.alpha = targetAlpha;
                } completion:^(BOOL finished){
                    [countButton setCount:[scrapsHeldInBezel count]];
                    [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        // bounce back
                        bubble.scale = 1.1;
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:animationDuration * .16 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            // and done
                            bubble.scale = 1.0;
                        } completion:^(BOOL finished){
                            [self.bubbleDelegate didAddScrapToBezelSidebar:scrap];
                        }];
                    }];
                }];
            }];
        }else if([scrapsHeldInBezel count] > kMaxScrapsInBezel){
            // we need to merge all the bubbles together into
            // a single button during the bezel animation
            [countButton setCount:[scrapsHeldInBezel count]];
            bubble.center = countButton.center;
            bubble.scale = 1;
            [UIView animateWithDuration:animationDuration * .51 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                // animate the scrap into position
                countButton.alpha = 1;
                for(MMScrapBubbleButton* bubble in self.subviews){
                    if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
                        bubble.alpha = 0;
                        bubble.center = countButton.center;
                    }
                }
                scrap.transform = CGAffineTransformConcat([MMScrapBubbleButton idealTransformForScrap:scrap], CGAffineTransformMakeScale(bubble.scale, bubble.scale));
                scrap.center = bubble.center;
            } completion:^(BOOL finished){
                // add it to the bubble and bounce
                bubble.scrap = scrap;
                [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    // scrap "hits" the bubble and pushes it down a bit
                    countButton.scale = .8;
                } completion:^(BOOL finished){
                    [countButton setCount:[scrapsHeldInBezel count]];
                    [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        // bounce back
                        countButton.scale = 1.1;
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:animationDuration * .16 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            // and done
                            countButton.scale = 1.0;
                        } completion:^(BOOL finished){
                            [self.bubbleDelegate didAddScrapToBezelSidebar:scrap];
                        }];
                    }];
                }];
            }];
        }
    }else{
        if([scrapsHeldInBezel count] <= kMaxScrapsInBezel){
            bubble.alpha = 1;
            scrap.transform = CGAffineTransformConcat([MMScrapBubbleButton idealTransformForScrap:scrap], CGAffineTransformMakeScale(bubble.scale, bubble.scale));
            scrap.center = bubble.center;
            bubble.scrap = scrap;
            for(MMScrapBubbleButton* anyBubble in self.subviews){
                if([anyBubble isKindOfClass:[MMScrapBubbleButton class]]){
                    int index = [scrapsHeldInBezel indexOfObject:anyBubble.scrap];
                    anyBubble.center = [self centerForBubbleAtIndex:index];
                }
            }
        }else{
            [countButton setCount:[scrapsHeldInBezel count]];
            countButton.alpha = 1;
            for(MMScrapBubbleButton* bubble in self.subviews){
                if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
                    bubble.alpha = 0;
                    bubble.center = countButton.center;
                }
            }
            scrap.transform = CGAffineTransformConcat([MMScrapBubbleButton idealTransformForScrap:scrap], CGAffineTransformMakeScale(bubble.scale, bubble.scale));
            scrap.center = bubble.center;
            bubble.scrap = scrap;
        }
    }
}

#pragma mark - Button Tap

-(void) bubbleTapped:(UITapGestureRecognizer*)gesture{
    MMScrapBubbleButton* bubble = (MMScrapBubbleButton*) gesture.view;
    if([scrapsHeldInBezel containsObject:bubble.scrap]){
        [scrapsHeldInBezel removeObject:bubble.scrap];
        
        MMScrapView* scrap = bubble.scrap;
        scrap.center = [self convertPoint:scrap.center fromView:scrap.superview];
        scrap.rotation += (bubble.rotation - bubble.rotationAdjustment);
        scrap.transform = CGAffineTransformConcat([MMScrapBubbleButton idealTransformForScrap:scrap], CGAffineTransformMakeScale(bubble.scale, bubble.scale));
        [self insertSubview:scrap atIndex:0];
        
        [self animateAndAddScrapBackToPage:scrap];
        
        [bubbleForScrap removeObjectForKey:scrap.uuid];
        [rotationAdjustments removeObjectForKey:scrap.uuid];
    }
}

-(void) didTapOnScrapFromMenu:(MMScrapView*)scrap{
    [scrapsHeldInBezel removeObject:scrap];

    scrap.center = [self convertPoint:scrap.center fromView:scrap.superview];
    [self insertSubview:scrap atIndex:0];
    
    [self sidebarCloseButtonWasTapped];
    [self animateAndAddScrapBackToPage:scrap];
    [countButton setCount:[scrapsHeldInBezel count]];

    [bubbleForScrap removeObjectForKey:scrap.uuid];
}

-(void) animateAndAddScrapBackToPage:(MMScrapView*)scrap{
    MMScrapBubbleButton* bubble = [bubbleForScrap objectForKey:scrap.uuid];
    [scrap loadStateAsynchronously:YES];
    
    CGPoint positionOnScreenToScaleTo = [self.bubbleDelegate positionOnScreenToScaleScrapTo:scrap];
    CGFloat scaleOnScreenToScaleTo = [self.bubbleDelegate scaleOnScreenToScaleScrapTo:scrap givenOriginalScale:bubble.originalScrapScale];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        scrap.center = positionOnScreenToScaleTo;
        [scrap setScale:scaleOnScreenToScaleTo andRotation:scrap.rotation];
    } completion:^(BOOL finished){
        [self.bubbleDelegate didAddScrapBackToPage:scrap];
    }];
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        bubble.alpha = 0;
        for(MMScrapBubbleButton* otherBubble in self.subviews){
            if(otherBubble != countButton && [otherBubble isKindOfClass:[MMScrapBubbleButton class]]){
                if(otherBubble != bubble){
                    int index = [scrapsHeldInBezel indexOfObject:otherBubble.scrap];
                    otherBubble.center = [self centerForBubbleAtIndex:index];
                    if([scrapsHeldInBezel count] <= kMaxScrapsInBezel){
                        otherBubble.scrap = otherBubble.scrap; // reset it
                        otherBubble.alpha = 1;
                    }
                }
            }
        }
        if([scrapsHeldInBezel count] <= kMaxScrapsInBezel){
            countButton.alpha = 0;
        }
    } completion:^(BOOL finished){
        [bubble removeFromSuperview];
    }];
}


// count button was tapped,
// so show or hide the menu
// so the user can choose a scrap to add
-(void) countButtonTapped:(UIButton*)button{
    if(countButton.alpha){
        countButton.alpha = 0;
        [contentView prepareContentView];
        [self show:YES];
    }
}

#pragma mark - Rotation

-(CGFloat) sidebarButtonRotationForReading:(CGFloat)currentReading{
    return -(currentReading + M_PI/2);
}

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    lastRotationReading = [self sidebarButtonRotationForReading:currentRawReading];
    for(MMScrapBubbleButton* bubble in self.subviews){
        if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
            // during an animation, the scrap will also be a subview,
            // so we need to make sure that we're rotating only the
            // bubble button
            bubble.rotation = [self sidebarButtonRotationForReading:currentRawReading];
        }
    }
}


#pragma mark - Ignore Touches

/**
 * these two methods make sure that this scrap container view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for(MMScrapBubbleButton* bubble in self.subviews){
        if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
            UIView* output = [bubble hitTest:[self convertPoint:point toView:bubble] withEvent:event];
            if(output) return output;
        }
    }
    if(contentView.alpha){
        UIView* output = [contentView hitTest:[self convertPoint:point toView:contentView] withEvent:event];
        if(output) return output;
    }
    return [super hitTest:point withEvent:event];
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for(MMScrapBubbleButton* bubble in self.subviews){
        if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
            if([bubble pointInside:[self convertPoint:point toView:bubble] withEvent:event]){
                return YES;
            }
        }
    }
    return [super pointInside:point withEvent:event];
}



#pragma mark - Save and Load


static NSString* bezelStatePath;


+(NSString*) pathToPlist{
    if(!bezelStatePath){
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"BezelState"];
        
        [NSFileManager ensureDirectoryExistsAtPath:bezelStateDirectory];
        bezelStatePath = [[bezelStateDirectory stringByAppendingPathComponent:@"info"] stringByAppendingPathExtension:@"plist"];
    }
    return bezelStatePath;
}

-(void) saveToDisk{
    [[scrapState immutableState] saveToDisk];
    
    [[rotationAdjustments copy] writeToFile:[MMScrapSidebarContainerView pathToPlist] atomically:YES];
}


#pragma mark - MMScrapsOnPaperStateDelegate & MMScrapBezelMenuViewDelegate

-(NSArray*) scraps{
    return  [scrapsHeldInBezel array];
}

-(void) didLoadScrap:(MMScrapView *)scrap{
    // add to the bezel
    NSNumber* rotationAdjustment = [rotationAdjustments objectForKey:scrap.uuid];
    scrap.rotation += [rotationAdjustment floatValue];
    [scrapsHeldInBezel addObject:scrap];
}

-(void) didLoadAllScrapsFor:(MMScrapsOnPaperState*)scrapState{
    NSArray* allScraps = [scrapsHeldInBezel copy];
    [scrapsHeldInBezel removeAllObjects];
    for(MMScrapView* scrap in [allScraps reverseObjectEnumerator]){
        [self addScrapToBezelSidebar:scrap animated:NO];
    }
}

@end

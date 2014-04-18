//
//  MMScrapPaperStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapPaperStackView.h"
#import "MMUntouchableView.h"
#import "MMScrapSidebarContainerView.h"
#import "MMDebugDrawView.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMStretchScrapGestureRecognizer.h"
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import "NSMutableSet+Extras.h"
#import "UIGestureRecognizer+GestureDebug.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMImageSidebarContainerView.h"
#import "MMBufferedImageView.h"

@implementation MMScrapPaperStackView{
    MMScrapSidebarContainerView* bezelScrapContainer;
    MMUntouchableView* scrapContainer;
    // we get two gestures here, so that we can support
    // grabbing two scraps at the same time
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture2;
    MMStretchScrapGestureRecognizer* stretchScrapGesture;

    // this is the initial transform of a scrap
    // before it's started to be stretched.
    CATransform3D startSkewTransform;
    
    // the scrap button that shows the count
    // in the right sidebar
    MMCountBubbleButton* countButton;
    
    // image picker sidebar
    MMImageSidebarContainerView* imagePicker;

    NSTimer* debugTimer;
    NSTimer* drawTimer;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
//        debugTimer = [NSTimer scheduledTimerWithTimeInterval:10
//                                                                  target:self
//                                                                selector:@selector(timerDidFire:)
//                                                                userInfo:nil
//                                                                 repeats:YES];

        
//        drawTimer = [NSTimer scheduledTimerWithTimeInterval:.5
//                                                      target:self
//                                                    selector:@selector(drawTimerDidFire:)
//                                                    userInfo:nil
//                                                     repeats:YES];

        
        CGFloat rightBezelSide = frame.size.width - 100;
        CGFloat midPointY = (frame.size.height - 3*80) / 2;
        countButton = [[MMCountBubbleButton alloc] initWithFrame:CGRectMake(rightBezelSide, midPointY - 60, 80, 80)];
        countButton.alpha = 0;
        [countButton addTarget:self action:@selector(showScrapSidebar:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:countButton belowSubview:addPageSidebarButton];

        bezelScrapContainer = [[MMScrapSidebarContainerView alloc] initWithFrame:self.bounds andCountButton:countButton];
        bezelScrapContainer.delegate = self;
        bezelScrapContainer.bubbleDelegate = self;
        [self insertSubview:bezelScrapContainer belowSubview:countButton];
        [bezelScrapContainer setCountButton:countButton];
        


        panAndPinchScrapGesture = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture.scrapDelegate = self;
        panAndPinchScrapGesture.cancelsTouchesInView = NO;
        panAndPinchScrapGesture.delegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture];
        
        panAndPinchScrapGesture2 = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture2.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture2.scrapDelegate = self;
        panAndPinchScrapGesture2.cancelsTouchesInView = NO;
        panAndPinchScrapGesture2.delegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture2];
        
        stretchScrapGesture = [[MMStretchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(stretchScrapGesture:)];
        stretchScrapGesture.scrapDelegate = self;
        stretchScrapGesture.pinchScrapGesture1 = panAndPinchScrapGesture;
        stretchScrapGesture.pinchScrapGesture2 = panAndPinchScrapGesture2;
        stretchScrapGesture.delegate = self;
        [self addGestureRecognizer:stretchScrapGesture];
        
        // make sure sidebar buttons hide the scrap menu
        for(MMSidebarButton* possibleSidebarButton in self.subviews){
            if([possibleSidebarButton isKindOfClass:[MMSidebarButton class]]){
                [possibleSidebarButton addTarget:self action:@selector(anySidebarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    
//        UIButton* drawLongElementButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 60)];
//        [drawLongElementButton addTarget:self action:@selector(drawLine) forControlEvents:UIControlEventTouchUpInside];
//        [drawLongElementButton setTitle:@"Draw Line" forState:UIControlStateNormal];
//        drawLongElementButton.backgroundColor = [UIColor whiteColor];
//        drawLongElementButton.layer.borderColor = [UIColor blackColor].CGColor;
//        drawLongElementButton.layer.borderWidth = 1;
//        [self addSubview:drawLongElementButton];
        
        [insertImageButton addTarget:self action:@selector(insertImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        imagePicker = [[MMImageSidebarContainerView alloc] initWithFrame:self.bounds forButton:insertImageButton animateFromLeft:YES];
        imagePicker.delegate = self;
        [imagePicker hide:NO];
        [self addSubview:imagePicker];
        
        scrapContainer = [[MMUntouchableView alloc] initWithFrame:self.bounds];
        [self addSubview:scrapContainer];
        
        
        fromRightBezelGesture.panDelegate = self;
    }
    return self;
}


#pragma mark - Insert Image

-(void) insertImageButtonTapped:(UIButton*)_button{
    [self cancelAllGestures];
    [[visibleStackHolder peekSubview] cancelAllGestures];
    [self setButtonsVisible:NO withDuration:0.15];
    [imagePicker show:YES];
}

#pragma mark - MMImageSidebarContainerViewDelegate

-(void) sidebarCloseButtonWasTapped{
    // noop
}

-(void) sidebarWillShow{
    [[MMDrawingTouchGestureRecognizer sharedInstace] setEnabled:NO];
}

-(void) sidebarWillHide{
    [self setButtonsVisible:YES];
    [[MMDrawingTouchGestureRecognizer sharedInstace] setEnabled:YES];
}

-(void) photoWasTapped:(ALAsset *)asset fromView:(MMBufferedImageView *)bufferedImage{
    CGRect scrapRect = CGRectZero;
    scrapRect.origin = [self convertPoint:[bufferedImage visibleImageOrigin] fromView:bufferedImage];
    scrapRect.size = [bufferedImage visibleImageSize];
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:scrapRect];

    //
    // to exactly align the scrap with a rotation,
    // i would need to rotate it around its top left corner
    // this is because we're creating the rect to align
    // with the point tl above, which when converted
    // into our coordinate system accounts for the view's
    // rotation.
    //
    // so at this moment, we have a squared off CGRect
    // that aligns it's top left corner to the rotated
    // bufferedImage's top left corner
    
    
    // max image size in any direction is 300pts
    CGFloat maxDim = 600;
    
    CGSize fullScale = [[asset defaultRepresentation] dimensions];
    if(fullScale.width >= fullScale.height && fullScale.width > maxDim){
        fullScale.height = fullScale.height / fullScale.width * maxDim;
        fullScale.width = maxDim;
    }else if(fullScale.height >= fullScale.width && fullScale.height > maxDim){
        fullScale.width = fullScale.width / fullScale.height * maxDim;
        fullScale.height = maxDim;
    }
    
    CGFloat startingScale = scrapRect.size.width / fullScale.width;
    
    UIImage* scrapBacking = [asset aspectThumbnailWithMaxPixelSize:300];
    
    MMScrappedPaperView* topPage = [visibleStackHolder peekSubview];
    MMScrapView* scrap = [topPage addScrapWithPath:path andRotation:0 andScale:startingScale];
    [scrapContainer addSubview:scrap];
    
    CGSize fullScaleScrapSize = scrapRect.size;
    fullScaleScrapSize.width /= startingScale;
    fullScaleScrapSize.height /= startingScale;
    
    // zoom the background in an extra pixel
    // so that the border of the image exceeds the
    // path of the scrap. this'll give us a nice smooth
    // edge from the mask of the CAShapeLayer
    CGFloat scaleUpOfImage = fullScaleScrapSize.width / scrapBacking.size.width + 2.0/scrapBacking.size.width; // extra pixel
    
    [scrap setBackingImage:scrapBacking];
    [scrap setBackgroundScale:scaleUpOfImage];
    scrap.center = [self convertPoint:CGPointMake(bufferedImage.bounds.size.width/2, bufferedImage.bounds.size.height/2) fromView:bufferedImage];
    scrap.rotation = bufferedImage.rotation;
    
    [imagePicker hide:YES];
    
    // hide the photo in the row
    bufferedImage.alpha = 0;
    
    // bounce by 20px (10 on each side)
    CGFloat bounceScale = 20 / MAX(fullScale.width, fullScale.height);
    
    [UIView animateWithDuration:.2
                          delay:.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         scrap.center = [visibleStackHolder peekSubview].center;
                         [scrap setScale:(1+bounceScale) andRotation:RandomPhotoRotation];
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:.1
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              [scrap setScale:1];
                                          }
                                          completion:^(BOOL finished){
                                              bufferedImage.alpha = 1;
                                              [topPage addScrap:scrap];
                                              [topPage saveToDisk];
                                          }];
                     }];
}

#pragma mark - Gesture Helpers

-(void) cancelAllGestures{
    [super cancelAllGestures];
    [panAndPinchScrapGesture cancel];
    [panAndPinchScrapGesture2 cancel];
    [stretchScrapGesture cancel];
}


static int numLines = 0;
BOOL skipOnce = NO;
int skipAll = NO;

-(void) drawTimerDidFire:(NSTimer*)timer{
    if(skipOnce){
        skipOnce = NO;
        return;
    }
    
    MMEditablePaperView* page = [visibleStackHolder peekSubview];
    
    MoveToPathElement* moveTo = [MoveToPathElement elementWithMoveTo:CGPointMake(rand() % (int) page.bounds.size.width, rand() % (int) page.bounds.size.height)];
    moveTo.width = 3;
    moveTo.color = [UIColor blackColor];
    
    CurveToPathElement* curveTo = [CurveToPathElement elementWithStart:moveTo.startPoint
                                                             andLineTo:CGPointMake(rand() % (int) page.bounds.size.width, rand() % (int) page.bounds.size.height)];
    curveTo.width = 3;
    curveTo.color = [UIColor blackColor];
    
    NSArray* shortLine = [NSArray arrayWithObjects:
                          moveTo,
                          curveTo,
                          nil];
    
    [page.drawableView addElements:shortLine];
    
    [page saveToDisk];
    
    numLines++;
    
    
    CGFloat strokesPerPage = 15;
    
    if(numLines % (int)strokesPerPage == 12){
        [[visibleStackHolder peekSubview] completeScissorsCutWithPath:[UIBezierPath bezierPathWithRect:CGRectMake(300, 300, 200, 200)]];
    }
    if(numLines % (int)strokesPerPage == 0){
        [self addPageButtonTapped:nil];
        skipOnce = YES;
    }
    
    NSLog(@"auto-lines: %d   pages: %d", numLines, (int) floor(numLines / strokesPerPage));
}


-(NSString*) activeGestureSummary{
    
    NSMutableString* str = [NSMutableString stringWithString:@"\n\n\n"];
    [str appendString:@"begin\n"];
    
    for(MMPaperView* page in setOfPagesBeingPanned){
        if([visibleStackHolder containsSubview:page]){
            [str appendString:@"  1 page in visible stack\n"];
        }else if([bezelStackHolder containsSubview:page]){
            [str appendString:@"  1 page in bezel stack\n"];
        }else if([hiddenStackHolder containsSubview:page]){
            [str appendString:@"  1 page in hidden stack\n"];
        }
    }
    
    
    NSArray* allGesturesAndTopTwoPages = [self.gestureRecognizers arrayByAddingObjectsFromArray:[[visibleStackHolder peekSubview] gestureRecognizers]];
    allGesturesAndTopTwoPages = [allGesturesAndTopTwoPages arrayByAddingObjectsFromArray:[[visibleStackHolder getPageBelow:[visibleStackHolder peekSubview]] gestureRecognizers]];
    for(UIGestureRecognizer* gesture in allGesturesAndTopTwoPages){
        UIGestureRecognizerState st = gesture.state;
        [str appendFormat:@"%@ %d", NSStringFromClass([gesture class]), st];
        if([gesture respondsToSelector:@selector(validTouches)]){
            [str appendFormat:@"   validTouches: %d", [[gesture performSelector:@selector(validTouches)] count]];
        }
        if([gesture respondsToSelector:@selector(touches)]){
            [str appendFormat:@"   touches: %d", [[gesture performSelector:@selector(touches)] count]];
        }
        if([gesture respondsToSelector:@selector(possibleTouches)]){
            [str appendFormat:@"   possibleTouches: %d", [[gesture performSelector:@selector(possibleTouches)] count]];
        }
        if([gesture respondsToSelector:@selector(ignoredTouches)]){
            [str appendFormat:@"   ignoredTouches: %d", [[gesture performSelector:@selector(ignoredTouches)] count]];
        }
        if([gesture respondsToSelector:@selector(paused)]){
            [str appendFormat:@"   paused: %d", [gesture performSelector:@selector(paused)] ? 1 : 0];
        }
        if([gesture respondsToSelector:@selector(scrap)]){
            [str appendFormat:@"   has scrap: %d", [gesture performSelector:@selector(scrap)] ? 1 : 0];
        }
    }
    [str appendFormat:@"velocity gesture sees: %d", [[MMTouchVelocityGestureRecognizer sharedInstace] numberOfActiveTouches]];
    [str appendFormat:@"pages being panned %d", [setOfPagesBeingPanned count]];
    
    [str appendFormat:@"done"];
    
    for(MMScrapView* scrap in [[visibleStackHolder peekSubview] scraps]){
        [str appendFormat:@"scrap: %f %f", scrap.layer.anchorPoint.x, scrap.layer.anchorPoint.y];
    }
    return str;
}


-(void) timerDidFire:(NSTimer*)timer{
    NSLog(@"%@", [self activeGestureSummary]);
}

-(void) drawLine{
    [[[visibleStackHolder peekSubview] drawableView] drawLongLine];
}

#pragma mark - Add Page

-(void) addPageButtonTapped:(UIButton*)_button{
    [self forceScrapToScrapContainerDuringGesture];
    [super addPageButtonTapped:_button];
}

-(void) anySidebarButtonTapped:(id)button{
    if(button != countButton){
        [bezelScrapContainer sidebarCloseButtonWasTapped];
    }
}

#pragma mark - MMPencilAndPaletteViewDelegate

-(void) penTapped:(UIButton*)_button{
    [super penTapped:_button];
    [self anySidebarButtonTapped:nil];
}

-(void) colorMenuToggled{
    [super colorMenuToggled];
    [self anySidebarButtonTapped:nil];
}

-(void) didChangeColorTo:(UIColor*)color{
    [super didChangeColorTo:color];
    [self anySidebarButtonTapped:nil];
}

#pragma mark - Bezel Gestures

-(void) forceScrapToScrapContainerDuringGesture{
    // if the gesture is cancelled, then don't move the scrap. to fix bezelling left over a scrap
    if(panAndPinchScrapGesture.scrap && panAndPinchScrapGesture.state != UIGestureRecognizerStateCancelled){
        if(![scrapContainer.subviews containsObject:panAndPinchScrapGesture.scrap]){
            [scrapContainer addSubview:panAndPinchScrapGesture.scrap];
            [self panAndScaleScrap:panAndPinchScrapGesture];
        }
    }
    if(panAndPinchScrapGesture2.scrap && panAndPinchScrapGesture2.state != UIGestureRecognizerStateCancelled){
        if(![scrapContainer.subviews containsObject:panAndPinchScrapGesture2.scrap]){
            [scrapContainer addSubview:panAndPinchScrapGesture2.scrap];
            [self panAndScaleScrap:panAndPinchScrapGesture2];
        }
    }
}

-(void) isBezelingInLeftWithGesture:(MMBezelInLeftGestureRecognizer*)bezelGesture{
    [super isBezelingInLeftWithGesture:bezelGesture];
    [self forceScrapToScrapContainerDuringGesture];
}

-(void) isBezelingInRightWithGesture:(MMBezelInRightGestureRecognizer *)bezelGesture{
    [super isBezelingInRightWithGesture:bezelGesture];
    [self forceScrapToScrapContainerDuringGesture];
}


#pragma mark - Panning Scraps

-(void) panAndScaleScrap:(MMPanAndPinchScrapGestureRecognizer*)_panGesture{
    MMPanAndPinchScrapGestureRecognizer* gesture = (MMPanAndPinchScrapGestureRecognizer*)_panGesture;

    if(_panGesture.paused){
        return;
    }
    // TODO:
    // the first time the gesture comes back unpaused,
    // we need to make sure the scrap is in the correct place

    //
    BOOL didReset = NO;
    if(gesture.shouldReset){
        gesture.shouldReset = NO;
        didReset = YES;
    }
    
    if(gesture.scrap && (gesture.scrap != stretchScrapGesture.scrap) && gesture.state != UIGestureRecognizerStateCancelled){
        
        // handle the scrap.
        //
        // if the scrap is hovering over the page that it
        // originated from, then make sure to keep it
        // inside that page so that picking up a scrap
        // doesn't change the order of the scrap in the page

        //
        // first step:
        // find the center, scale, and rotation for the scrap
        // independent of any page
        MMScrapView* scrap = gesture.scrap;
        scrap.center = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                   gesture.translation.y + gesture.preGestureCenter.y);
        scrap.scale = gesture.preGestureScale * gesture.scale * gesture.preGesturePageScale;
        scrap.rotation = gesture.rotation + gesture.preGestureRotation;

        //
        // now determine if it should be inside of a page,
        // and what the page specific center and scale should be
        CGFloat scrapScaleInPage;
        CGPoint scrapCenterInPage;
        MMScrappedPaperView* pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
        if(![pageToDropScrap isEqual:[visibleStackHolder peekSubview]]){
            // if the page it should drop isn't the top visible page,
            // then add it to the scrap container view.
            if(![scrapContainer.subviews containsObject:scrap]){
                // just keep it in the scrap container
                [scrapContainer addSubview:scrap];
            }
        }else if(pageToDropScrap && [pageToDropScrap hasScrap:scrap]){
            // only adjust for the page if the page
            // already has the scrap. otherwise we'll keep
            // the scrap in the container view and only drop
            // it onto a page once the gesture is complete.
            gesture.scrap.scale = scrapScaleInPage;
            gesture.scrap.center = scrapCenterInPage;
        }
        
        if(gesture.isShaking){
            // if the gesture is shaking, then pull the scrap to the top if
            // it's not already. otherwise send it to the back
            if([pageToDropScrap isEqual:[visibleStackHolder peekSubview]] &&
               ![pageToDropScrap hasScrap:scrap]){
                [pageToDropScrap addScrap:scrap];
                [gesture.scrap.superview insertSubview:gesture.scrap atIndex:0];
            }else if(gesture.scrap == [gesture.scrap.superview.subviews lastObject]){
                [gesture.scrap.superview insertSubview:gesture.scrap atIndex:0];
            }else{
                [gesture.scrap.superview addSubview:gesture.scrap];
            }
        }
        
        
        [self isBeginningToPanAndScaleScrapWithTouches:gesture.validTouches];
    }
    
    MMScrapView* scrapViewIfFinished = nil;
    
    BOOL shouldBezel = NO;
    if(gesture.state == UIGestureRecognizerStateEnded ||
       gesture.state == UIGestureRecognizerStateCancelled ||
       ![gesture.validTouches count]){
        // turn off glow
        if(!stretchScrapGesture.scrap){
            // only if that scrap isn't being stretched
            gesture.scrap.selected = NO;
        }
        
        //
        // notes for dropping scraps:
        //
        // Since the "center" of a scrap is changed to the gesture
        // location, I only need to check if the scrap center
        // is inside of a page, and make sure to add the scrap
        // to that page.
        
        NSArray* scrapsInContainer = scrapContainer.subviews;
        
        if(gesture.didExitToBezel){
            shouldBezel = YES;
        }else if([scrapsInContainer containsObject:gesture.scrap]){
            CGFloat scrapScaleInPage;
            CGPoint scrapCenterInPage;
            MMScrappedPaperView* pageToDropScrap;
            if(gesture.state == UIGestureRecognizerStateCancelled){
                pageToDropScrap = [visibleStackHolder peekSubview];
                [self scaledCenter:&scrapCenterInPage andScale:&scrapScaleInPage forScrap:gesture.scrap onPage:pageToDropScrap];
            }else{
                pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
            }
            if(pageToDropScrap){
                [pageToDropScrap addScrap:gesture.scrap];
                gesture.scrap.scale = scrapScaleInPage;
                gesture.scrap.center = scrapCenterInPage;
            }else{
                // couldn't find a page to catch it
                shouldBezel = YES;
            }
        }
        
        scrapViewIfFinished = gesture.scrap;
    }else if(gesture.scrap && didReset){
        // glow blue
        gesture.scrap.selected = YES;
    }
    if(gesture.scrap && (gesture.state == UIGestureRecognizerStateEnded ||
                         gesture.state == UIGestureRecognizerStateFailed ||
                         gesture.state == UIGestureRecognizerStateCancelled ||
                         ![gesture.validTouches count])){
        // after possibly rotating the scrap, we need to reset it's anchor point
        // and position, so that we can consistently determine it's position with
        // the center property
        
        
        // giving up the scrap will make sure
        // its anchor point is back in the true
        // center of the scrap. It'll also
        // nil out the scrap in the gesture, so
        // hang onto it
        MMScrapView* scrap = gesture.scrap;
        [gesture giveUpScrap];
        
        if(shouldBezel){
            // if we've bezelled the scrap,
            // add it to the bezel container
            [bezelScrapContainer addScrapToBezelSidebar:scrap animated:YES];
        }
    }
    if(scrapViewIfFinished){
        [self finishedPanningAndScalingScrap:scrapViewIfFinished];
    }
}


/**
 * this method will return the page that could contain the scrap
 * given it's current position on the screen and the pages' postions
 * on the screen.
 *
 * it will return the page that should "catch" the scrap, and the
 * center/scale for the scrap on that page
 *
 * if no page could catch it, this will return nil
 */
-(MMScrappedPaperView*) pageWouldDropScrap:(MMScrapView*)scrap atCenter:(CGPoint*)scrapCenterInPage andScale:(CGFloat*)scrapScaleInPage{
    MMScrappedPaperView* pageToDropScrap = nil;
    CGRect pageBounds;
    //
    // we want to be able to drop scraps
    // onto any page in the visible or bezel stack
    //
    // since the bezel pages are "above" the visible stack,
    // we should check them first
    //
    // these pages are in reverse order, so the last object in the
    // array is the top most visible page.
    
    //
    // I used to just create an NSMutableArray that contained the
    // combined visible and bezel stacks of subviews. but that was
    // fairly resource intensive for a method that needs to be extremely
    // quick.
    //
    // instead of an NSMutableArray, i create a C array pointing to
    // the arrays we already have. then our do:while loop will walk
    // backwards on the 2nd array, then walk backwards on the first
    // array until a page is found.
    NSArray* arrayOfArrayOfViews[2];
    arrayOfArrayOfViews[0] = visibleStackHolder.subviews;
    arrayOfArrayOfViews[1] = bezelStackHolder.subviews;
    int arrayNum = 1;
    int indexNum = [bezelStackHolder.subviews count] - 1;

    do{
        if(indexNum < 0){
            // if our index is less than zero, then we haven't been able
            // to find a page in our current array. move to the next array
            // of views further back in the view, and start checking those
            arrayNum -= 1;
            if(arrayNum == -1){
                // failsafe.
                // this may happen if the user picks up two scraps with system gestures turned on.
                // the system may exit our app, leaving us in an unknown state
                return [visibleStackHolder peekSubview];
            }
            indexNum = [(arrayOfArrayOfViews[arrayNum]) count] - 1;
        }
        // fetch the most visible page
        pageToDropScrap = [(arrayOfArrayOfViews[arrayNum]) objectAtIndex:indexNum];
        if(!pageToDropScrap){
            // if we can't find a page, we're done
            break;
        }
        [self scaledCenter:scrapCenterInPage andScale:scrapScaleInPage forScrap:scrap onPage:pageToDropScrap];
        // bounds respects the transform, so we need to scale the
        // bounds of the page too to see if the scrap is landing inside
        // of it
        pageBounds = pageToDropScrap.bounds;
        CGFloat pageScale = pageToDropScrap.scale;
        CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1/pageScale, 1/pageScale);
        pageBounds = CGRectApplyAffineTransform(pageBounds, reverseScaleTransform);

        indexNum -= 1;
    }while(!CGRectContainsPoint(pageBounds, *scrapCenterInPage));
    
    return pageToDropScrap;
}

-(void) scaledCenter:(CGPoint*)scrapCenterInPage andScale:(CGFloat*)scrapScaleInPage forScrap:(MMScrapView*)scrap onPage:(MMScrappedPaperView*)pageToDropScrap{
    CGFloat pageScale = pageToDropScrap.scale;
    CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1/pageScale, 1/pageScale);
    *scrapScaleInPage = scrap.scale;
    *scrapCenterInPage = scrap.center;
    *scrapScaleInPage = *scrapScaleInPage / pageScale;
    *scrapCenterInPage = [pageToDropScrap convertPoint:*scrapCenterInPage fromView:scrapContainer];
    *scrapCenterInPage = CGPointApplyAffineTransform(*scrapCenterInPage, reverseScaleTransform);
}

#pragma mark - MMStretchScrapGestureRecognizer

// this is called through the stretch of a
// scrap.
-(void) stretchScrapGesture:(MMStretchScrapGestureRecognizer*)gesture{
    if(gesture.scrap){
        // don't allow animations during a stretch
        [gesture.scrap.layer removeAllAnimations];
        if(!CGPointEqualToPoint(gesture.scrap.layer.anchorPoint, CGPointZero)){
            // the anchor point can get reset by the pan/pinch gesture ending,
            // so we need to force it back to our 0,0 for the stretch
            [UIView setAnchorPoint:CGPointMake(0, 0) forView:gesture.scrap];
        }
        // cancel any strokes etc happening with these touches
        [self isBeginningToPanAndScaleScrapWithTouches:gesture.validTouches];
        
        // generate the actual transform between the two quads
        gesture.scrap.layer.transform = CATransform3DConcat(startSkewTransform, [gesture skewTransform]);
    }
}

-(CGPoint) beginStretchForScrap:(MMScrapView*)scrap{
//    NSLog(@"beginStretchForScrap");
//    [panAndPinchScrapGesture say:@"beginning start" ISee:[NSSet setWithArray:panAndPinchScrapGesture.validTouches]];
//    [panAndPinchScrapGesture2 say:@"beginning start" ISee:[NSSet setWithArray:panAndPinchScrapGesture2.validTouches]];
//    [stretchScrapGesture say:@"beginning start" ISee:[NSSet setWithArray:stretchScrapGesture.validTouches]];

    
    if(![scrapContainer.subviews containsObject:scrap]){
        MMPanAndPinchScrapGestureRecognizer* owningPan = panAndPinchScrapGesture.scrap == scrap ? panAndPinchScrapGesture : panAndPinchScrapGesture2;
        scrap.center = CGPointMake(owningPan.translation.x + owningPan.preGestureCenter.x,
                                   owningPan.translation.y + owningPan.preGestureCenter.y);
        scrap.scale = owningPan.preGestureScale * owningPan.scale * owningPan.preGesturePageScale;
        scrap.rotation = owningPan.rotation + owningPan.preGestureRotation;
        [scrapContainer addSubview:scrap];
    }
    
    // now, for our stretch gesture, we need the anchor point
    // to be at the 0,0 point of the scrap so that the transform
    // works properly to stretch the scrap.
    [UIView setAnchorPoint:CGPointMake(0, 0) forView:scrap];
    // the user has just now begun to hold a scrap
    // with four fingers and is stretching it.
    // set the anchor point to 0,0 for the skew transform
    // and keep our initial scale/rotate transform so
    // we can animate back to it when we're done
    scrap.selected = YES;
    startSkewTransform = scrap.layer.transform;
    
    //
    // keep the pan gestures alive, just pause them from
    // updating until after the stretch gesture so we can
    // handoff the newly stretched/moved/adjusted scrap
    // seemlessly
    [panAndPinchScrapGesture pause];
    [panAndPinchScrapGesture2 pause];
    return [scrap convertPoint:scrap.bounds.origin toView:visibleStackHolder];
}

// the stretch failed or ended before splitting, so give
// the pan gesture back it's scrap if its still alive
-(void) endStretchWithoutSplittingScrap:(MMScrapView*)scrap atNormalPoint:(CGPoint)np{
    [stretchScrapGesture say:@"ending start" ISee:[NSSet setWithArray:stretchScrapGesture.validTouches]];
    
    // check the gestures first to see if they're still alive,
    // and give the scrap back if possible.
    NSSet* validTouches = [NSSet setWithArray:[stretchScrapGesture validTouches]];
    if(panAndPinchScrapGesture.scrap == scrap){
        [panAndPinchScrapGesture say:@"ending start" ISee:[NSSet setWithArray:panAndPinchScrapGesture.validTouches]];
        // gesture 1 owns it, so give it back and turn gesture 2 back on
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:validTouches];
        [self sendStretchedScrap:scrap toPanGesture:panAndPinchScrapGesture withTouches:[stretchScrapGesture validTouches] withAnchor:np];
        [panAndPinchScrapGesture2 begin];
    }else if(panAndPinchScrapGesture2.scrap == scrap){
        [panAndPinchScrapGesture2 say:@"ending start" ISee:[NSSet setWithArray:panAndPinchScrapGesture2.validTouches]];
        // gesture 2 owns it, so give it back and turn gesture 1 back on
        [panAndPinchScrapGesture relinquishOwnershipOfTouches:validTouches];
        [self sendStretchedScrap:scrap toPanGesture:panAndPinchScrapGesture2 withTouches:[stretchScrapGesture validTouches] withAnchor:np];
        [panAndPinchScrapGesture begin];
    }else if([stretchScrapGesture.validTouches count] >= 2){
        // neither has a scrap, but i have at least 2 touches to give away
        [panAndPinchScrapGesture say:@"ending start" ISee:[NSSet setWithArray:panAndPinchScrapGesture.validTouches]];
        // gesture 1 owns it, so give it back and turn gesture 2 back on
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:validTouches];
        [self sendStretchedScrap:scrap toPanGesture:panAndPinchScrapGesture withTouches:[stretchScrapGesture validTouches] withAnchor:np];
        [panAndPinchScrapGesture2 begin];
    }else{
        // neither has a scrap, and i don't have enough touches to give it away
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:validTouches];
        [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:validTouches];
        // otherwise, unpause both gestures and just
        // put the scrap back into the page
        [panAndPinchScrapGesture begin];
        [panAndPinchScrapGesture2 begin];
        scrap.layer.transform = startSkewTransform;
        [UIView setAnchorPoint:CGPointMake(.5, .5) forView:scrap];
        // kill highlight since it's not being held
        scrap.selected = NO;
        
        if(![[visibleStackHolder peekSubview] hasScrap:scrap]){
            // the scrap was dropped by the stretch gesture,
            // so just add it back to the top page
            [[visibleStackHolder peekSubview] addScrap:scrap];
        }
    }
}

// this is a helper method to give a scrap back to a particular
// pan gesture. this should trigger any animations necessary
// on the scrap, and facilitate the transition from the possibly
// stretched transform of the scrap back to it's pre-stretched
// transform.
-(void) sendStretchedScrap:(MMScrapView*)scrap toPanGesture:(MMPanAndPinchScrapGestureRecognizer*)panScrapGesture withTouches:(NSArray*)touches withAnchor:(CGPoint)scrapAnchor{
    
    if([touches count] < 2){
        @throw [NSException exceptionWithName:@"NotEnoughTouchesForPan" reason:@"streching a scrap ended, but doesn't have enough touches to give back to a pan gesture" userInfo:nil];
    }
    

    // bless the touches so that the pan gesture
    // can pick them up
    [panScrapGesture forceBlessTouches:[NSSet setWithArray:touches] forScrap:scrap];
    
    // now that we've calcualted the current position for our
    // reference anchor point, we should now adjust our anchor
    // back to 0,0 during the next transforms to bounce
    // the scrap back to its new place.
    [UIView setAnchorPoint:CGPointMake(0, 0) forView:scrap];
    scrap.layer.transform = startSkewTransform;
    
    // find out where the location should be inside the page
    // for the input two (at most) touches
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    CGPoint locationInPage = AveragePoints([[touches objectAtIndex:0] locationInView:page],
                                           [[touches objectAtIndex:1] locationInView:page]);
    
    // by setting the anchor point, the .center property will
    // automaticaly align the locationInPage to scrapAnchor
    [UIView setAnchorPoint:scrapAnchor forView:scrap];
    scrap.center = CGPointMake(locationInPage.x, locationInPage.y);
    if([panScrapGesture begin]){
        // if the pan gesture picked up the scrap,
        // then set it as still selected
        scrap.selected = YES;
    }else{
        // reset our anchor to the scrap center if a pan
        // isn't going to take over
        [UIView setAnchorPoint:CGPointMake(.5, .5) forView:scrap];
        // kill highlight since it's not being held
        scrap.selected = NO;
    }
}


-(void) logOutputGestureTouchOwnership:(NSString*) prefix gesture:(MMPanAndPinchScrapGestureRecognizer*)gesture{
    return;
    NSString* validOut = @"valid:";
    for (UITouch* t in gesture.validTouches) {
        validOut = [validOut stringByAppendingFormat:@" %p", t];
    }
    NSString* possibleOut = @"possible:";
    for (UITouch* t in gesture.possibleTouches) {
        possibleOut = [possibleOut stringByAppendingFormat:@" %p", t];
    }
    NSString* ignoredOut = @"ignored:";
    for (UITouch* t in gesture.ignoredTouches) {
        ignoredOut = [ignoredOut stringByAppendingFormat:@" %p", t];
    }
    NSLog(@"%@ (%p) knows about:\n%@\n%@\n%@ ", prefix, gesture, validOut, possibleOut, ignoredOut);
}


// time to duplicate the scraps! it's been pulled into two pieces
-(void) endStretchBySplittingScrap:(MMScrapView*)scrap toTouches:(NSOrderedSet*)touches1 atNormalPoint:(CGPoint)np1
                     andTouches:(NSOrderedSet*)touches2  atNormalPoint:(CGPoint)np2{

    [self logOutputGestureTouchOwnership:@"before gesture 1" gesture:panAndPinchScrapGesture];
    [self logOutputGestureTouchOwnership:@"before gesture 2" gesture:panAndPinchScrapGesture2];
    
    [panAndPinchScrapGesture relinquishOwnershipOfTouches:[touches2 set]];
    [panAndPinchScrapGesture2 relinquishOwnershipOfTouches:[touches1 set]];
    
    [self logOutputGestureTouchOwnership:@"relenquished gesture 1" gesture:panAndPinchScrapGesture];
    [self logOutputGestureTouchOwnership:@"relenquished gesture 2" gesture:panAndPinchScrapGesture2];
    
    [self sendStretchedScrap:scrap toPanGesture:panAndPinchScrapGesture withTouches:[touches1 array] withAnchor:np1];
    
    [self logOutputGestureTouchOwnership:@"after 1 set gesture 1" gesture:panAndPinchScrapGesture];
    [self logOutputGestureTouchOwnership:@"after 1 set gesture 2" gesture:panAndPinchScrapGesture2];


    // next, add the new scrap to the same page as the stretched scrap
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    // we need to send in scale 1.0 because the *path* scale we're sending in is for the 1.0 scaled path.
    // if we sent the scale into this method, it would assume that the input path was *already at* the input
    // scale, so it would transform the path to a 1.0 scale before adding the scrap. this would result in incorrect
    // resolution for the new scrap. so set the rotation to make sure we're getting the smallest bounding
    // box, and we'll set the scrap's scale to match after we add it to the page.
    MMScrapView* clonedScrap = [page addScrapWithPath:[scrap.bezierPath copy] andRotation:scrap.rotation andScale:1.0];
    // ok, now the scrap is added with the correct path and resolution, so set it's scale to match
    // the original scrap.
    clonedScrap.scale = scrap.scale;
    // next match it's location exactly on top of the original scrap:
    [UIView setAnchorPoint:scrap.layer.anchorPoint forView:clonedScrap];
    clonedScrap.center = scrap.center;
    
    // next, clone the contents onto the new scrap. at this point i have a duplicate scrap
    // but it's in the wrong place.
    [clonedScrap stampContentsFrom:scrap.state.drawableView];
    panAndPinchScrapGesture2.scrap = clonedScrap;
    
    // clone background contents too
    [clonedScrap setBackingImage:scrap.backingImage];
    [clonedScrap setBackgroundRotation:scrap.backgroundRotation];
    [clonedScrap setBackgroundScale:scrap.backgroundScale];
    [clonedScrap setBackgroundOffset:scrap.backgroundOffset];
    

    // move it to the new gesture location under it's scrap
    [UIView setAnchorPoint:CGPointMake(.5, .5) forView:clonedScrap];
    CGPoint p1 = [[touches2 objectAtIndex:0] locationInView:self];
    CGPoint p2 = [[touches2 objectAtIndex:1] locationInView:self];
    clonedScrap.center = AveragePoints(p1, p2);

    // time to reset the gesture for the cloned scrap
    // now the scrap is in the right place, so hand it off to the pan gesture
    [self sendStretchedScrap:clonedScrap toPanGesture:panAndPinchScrapGesture2 withTouches:[touches2 array] withAnchor:np2];
    
    [self logOutputGestureTouchOwnership:@"after 2 set gesture 1" gesture:panAndPinchScrapGesture];
    [self logOutputGestureTouchOwnership:@"after 2 set gesture 2" gesture:panAndPinchScrapGesture2];

    
    if(!panAndPinchScrapGesture.scrap || !panAndPinchScrapGesture2.scrap){
        // sanity checks.
        // we should never enter here
        if([panAndPinchScrapGesture.initialTouchVector isEqual:panAndPinchScrapGesture2.initialTouchVector]){
            NSLog(@"what");
        }
        
        if(scrap.scale != clonedScrap.scale ||
           scrap.rotation != clonedScrap.rotation){
            NSLog(@"what");
        }
        
        NSLog(@"success? %d %p,  %d %p", [panAndPinchScrapGesture.validTouches count], panAndPinchScrapGesture.scrap,
              [panAndPinchScrapGesture2.validTouches count], panAndPinchScrapGesture2.scrap);

        if([panAndPinchScrapGesture.validTouches count] < 2){
            [self logOutputGestureTouchOwnership:@"gesture 1 failed gesture 1" gesture:panAndPinchScrapGesture];
            [self logOutputGestureTouchOwnership:@"gesture 1 failed gesture 2" gesture:panAndPinchScrapGesture2];
        }
        if([panAndPinchScrapGesture2.validTouches count] < 2){
            [self logOutputGestureTouchOwnership:@"gesture 2 failed gesture 1" gesture:panAndPinchScrapGesture];
            [self logOutputGestureTouchOwnership:@"gesture 2 failed gesture 2" gesture:panAndPinchScrapGesture2];
        }
        @throw [NSException exceptionWithName:@"DroppedSplitScrap" reason:@"split scrap was dropped by pan gestures" userInfo:nil];
    }
}


#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

-(NSArray*) scraps{
    return [[[visibleStackHolder peekSubview] scraps] arrayByAddingObjectsFromArray:scrapContainer.subviews];
    
}

-(BOOL) panScrapRequiresLongPress{
    return rulerButton.selected;
}

-(CGFloat) topVisiblePageScaleForScrap:(MMScrapView*)scrap{
    if([scrapContainer.subviews containsObject:scrap]){
        return 1;
    }else{
        return [visibleStackHolder peekSubview].scale;
    }
}

-(CGPoint) convertScrapCenterToScrapContainerCoordinate:(MMScrapView*)scrap{
    CGPoint scrapCenter = scrap.center;
    if([scrapContainer.subviews containsObject:scrap]){
        return scrapCenter;
    }else{
        CGFloat pageScale = [visibleStackHolder peekSubview].scale;
        // because the page uses a transform to scale itself, the scrap center will always
        // be in page scale = 1.0 form. if the user picks up a scrap while also scaling the page,
        // then we need to transform that coordinate into the visible scale of the zoomed page.
        scrapCenter = CGPointApplyAffineTransform(scrapCenter, CGAffineTransformMakeScale(pageScale, pageScale));
        // now that the coordinate is in the visible scale, we can convert that directly to the
        // scapContainer's coodinate system
        return [[visibleStackHolder peekSubview] convertPoint:scrapCenter toView:scrapContainer];
    }
}


#pragma mark - MMPaperViewDelegate

-(CGRect) isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView *)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches{
    CGRect ret = [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
    if(panAndPinchScrapGesture.state == UIGestureRecognizerStateBegan){
        panAndPinchScrapGesture.state = UIGestureRecognizerStateChanged;
    }
    if(panAndPinchScrapGesture2.state == UIGestureRecognizerStateBegan){
        panAndPinchScrapGesture2.state = UIGestureRecognizerStateChanged;
    }
    [self panAndScaleScrap:panAndPinchScrapGesture];
    [self panAndScaleScrap:panAndPinchScrapGesture2];

    return ret;
}

-(void) setButtonsVisible:(BOOL)visible{
    [UIView animateWithDuration:.3 animations:^{
        bezelScrapContainer.alpha = visible ? 1 : 0;
    }];
    [super setButtonsVisible:visible];
}


-(void) isBeginningToPanAndScaleScrapWithTouches:(NSArray*)touches{
    // our gesture has began, so make sure to kill
    // any touches that are being used to draw
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for(UITouch* touch in touches){
        [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
        [scissor cancelPolygonForTouch:touch];
    }
}

-(void) finishedPanningAndScalingScrap:(MMScrapView*)scrap{
    // save page if we're not holding any scraps
    if(!panAndPinchScrapGesture.scrap && !panAndPinchScrapGesture2.scrap && !stretchScrapGesture.scrap){
        [[visibleStackHolder peekSubview] saveToDisk];
    }
}

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [super ownershipOfTouches:touches isGesture:gesture];
    if([gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]] ||
       [gesture isKindOfClass:[MMStretchScrapGestureRecognizer class]]){
        // only notify of our own gestures
        [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
    }
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
    [panAndPinchScrapGesture2 ownershipOfTouches:touches isGesture:gesture];
    [stretchScrapGesture ownershipOfTouches:touches isGesture:gesture];
}

-(void) didLongPressPage:(MMPaperView*)page withTouches:(NSSet*)touches{
    // if we're in ruler mode, then
    // let the pan scrap gestures know that they can move the scrap
    if([self panScrapRequiresLongPress]){
        //
        // if a long press happens, give the touches to
        // whichever scrap pan gesture doesn't have a scrap
        if(!panAndPinchScrapGesture.scrap){
            [panAndPinchScrapGesture blessTouches:touches];
        }else{
            [panAndPinchScrapGesture2 blessTouches:touches];
        }
        [stretchScrapGesture blessTouches:touches];
    }
}


#pragma mark - Rotation

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    if(1 - ABS(zAccel) > .03){
        [NSThread performBlockOnMainThread:^{
            [super didUpdateAccelerometerWithReading:currentRawReading];
            [bezelScrapContainer didUpdateAccelerometerWithRawReading:currentRawReading andX:xAccel andY:yAccel andZ:zAccel];
            [[visibleStackHolder peekSubview] didUpdateAccelerometerWithRawReading:currentRawReading];
        }];
    }
}

#pragma mark - MMScrapSidebarViewDelegate

-(void) showScrapSidebar:(UIButton*)button{
    // showing the actual sidebar is handled inside
    // the MMScrapSlidingSidebarView, which adds
    // its own target to the button
    [self cancelAllGestures];
}

-(void) didAddScrapToBezelSidebar:(MMScrapView *)scrap{
    [bezelScrapContainer saveToDisk];
}

-(void) didAddScrapBackToPage:(MMScrapView *)scrap{
    // first, find the page to add the scrap to.
    // this will check visible + bezelled pages to see
    // which page should get the scrap, and it'll tell us
    // the center/scale to use
    CGPoint center;
    CGFloat scale;
    MMScrappedPaperView* page = [self pageWouldDropScrap:scrap atCenter:&center andScale:&scale];

    // ok, done, just set it
    [page addScrap:scrap];
    scrap.center = center;
    scrap.scale = scale;
    [bezelScrapContainer saveToDisk];
}

-(CGPoint) positionOnScreenToScaleScrapTo:(MMScrapView*)scrap{
    return [visibleStackHolder center];
}

-(CGFloat) scaleOnScreenToScaleScrapTo:(MMScrapView*)scrap givenOriginalScale:(CGFloat)originalScale{
    return originalScale * [visibleStackHolder peekSubview].scale;
}



#pragma mark - List View

-(void) finishedScalingReallySmall:(MMPaperView *)page{
    if(panAndPinchScrapGesture.scrap){
        [panAndPinchScrapGesture cancel];
    }
    if(panAndPinchScrapGesture2.scrap){
        [panAndPinchScrapGesture2 cancel];
    }
    [super finishedScalingReallySmall:page];
}


#pragma mark - MMStretchScrapGestureRecognizerDelegate

// return all touches that fall within the input scrap's boundary
// and don't fall within any scrap above the input scrap
-(NSSet*) setOfTouchesFrom:(NSOrderedSet *)touches inScrap:(MMScrapView *)scrap{
    return nil;
}

@end

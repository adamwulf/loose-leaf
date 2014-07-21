//
//  MMScrapPaperStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "MMScrapPaperStackView.h"
#import "MMUntouchableView.h"
#import "MMScrapSidebarContainerView.h"
#import "MMDebugDrawView.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMStretchScrapGestureRecognizer.h"
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import <JotUI/UIImage+Resize.h>
#import "NSMutableSet+Extras.h"
#import "UIGestureRecognizer+GestureDebug.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMImageSidebarContainerView.h"
#import "MMBufferedImageView.h"
#import "MMBorderedCamView.h"
#import "MMInboxManager.h"
#import "MMInboxManagerDelegate.h"
#import "NSURL+UTI.h"
#import "Mixpanel.h"

@implementation MMScrapPaperStackView{
    MMScrapSidebarContainerView* bezelScrapContainer;
    MMScrapContainerView* scrapContainer;
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
    UIImageView* debugImgView;
    
    // flag if we're waiting on a page to save
    MMPaperView* wantsExport;
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

        [MMInboxManager sharedInstace].delegate = self;
        
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
        [self addGestureRecognizer:panAndPinchScrapGesture];
        
        panAndPinchScrapGesture2 = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture2.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture2.scrapDelegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture2];
        
        stretchScrapGesture = [[MMStretchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(stretchScrapGesture:)];
        stretchScrapGesture.scrapDelegate = self;
        stretchScrapGesture.pinchScrapGesture1 = panAndPinchScrapGesture;
        stretchScrapGesture.pinchScrapGesture2 = panAndPinchScrapGesture2;
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
        
        scrapContainer = [[MMScrapContainerView alloc] initWithFrame:self.bounds andPage:nil];
        scrapContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:scrapContainer];
        
        
        fromRightBezelGesture.panDelegate = self;
        fromLeftBezelGesture.panDelegate = self;

    
//        debugImgView = [[UIImageView alloc] initWithFrame:CGRectMake(380, 80, self.bounds.size.width / 3, self.bounds.size.height/3)];
//        debugImgView.layer.borderWidth = 1;
//        debugImgView.layer.borderColor = [UIColor redColor].CGColor;
//        debugImgView.contentMode = UIViewContentModeScaleAspectFit;
//        debugImgView.backgroundColor = [UIColor orangeColor];
//        [self addSubview:debugImgView];
    }
    return self;
}

-(void) finishedLoading{
    [bezelScrapContainer loadFromDisk];
}

-(int) fullByteSize{
    return [super fullByteSize] + imagePicker.fullByteSize + bezelScrapContainer.fullByteSize;
    
}

#pragma mark - Insert Image

-(void) insertImageButtonTapped:(UIButton*)_button{
    [self cancelAllGestures];
    [[visibleStackHolder peekSubview] cancelAllGestures];
    [self setButtonsVisible:NO withDuration:0.15];
    [imagePicker show:YES];
}

#pragma mark - MMInboxManagerDelegate

-(void) failedToProcessIncomingURL:(NSURL*)url fromApp:(NSString*)sourceApplication{
    NSLog(@"too bad! can't import file from %@", url);
    // log this to mixpanel
    [[Mixpanel sharedInstance] track:kMPEventImportPhotoFailed properties:@{kMPEventImportPropFileExt : [url fileExtension],
                                                                            kMPEventImportPropFileType : [url universalTypeID],
                                                                            kMPEventImportPropSource : kMPEventImportPropSourceApplication,
                                                                            kMPEventImportPropReferApp : sourceApplication}];
}

-(void) didProcessIncomingImage:(UIImage*)scrapBacking fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    // import after slight delay so the transition from the other app
    // can complete nicely
    [[NSThread mainThread] performBlock:^{
        NSLog(@"got image: %p scale: %f width: %f %f", scrapBacking, scale, scrapBacking.size.width, scrapBacking.size.height);
        
        MMVector* up = [[MMRotationManager sharedInstace] upVector];
        MMVector* perp = [[up perpendicular] normal];
        CGPoint center = CGPointMake(ceilf((self.bounds.size.width - scrapBacking.size.width) / 2),
                                     ceilf((self.bounds.size.height - scrapBacking.size.height) / 2));
        // start the photo "up" and have it drop down into the center ish of the page
        center = [up pointFromPoint:center distance:80];
        // randomize it a bit
        center = [perp pointFromPoint:center distance:(random() % 80) - 40];
        
        
        // subtract 1px from the border so that the background is clipped nicely around the edge
        CGSize scrapSize = CGSizeMake(scrapBacking.size.width - 2, scrapBacking.size.height - 2);
        UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(center.x, center.y, scrapSize.width, scrapSize.height)];
        
        MMScrappedPaperView* topPage = [visibleStackHolder peekSubview];
        MMScrapView* scrap = [topPage addScrapWithPath:path andRotation:RandomPhotoRotation andScale:1.0];
        [scrapContainer addSubview:scrap];
        
        // background fills the entire scrap
        [scrap setBackgroundView:[[MMScrapBackgroundView alloc] initWithImage:scrapBacking forScrapState:scrap.state]];
        

        // prep the scrap to fade in while it drops on screen
        scrap.alpha = .3;
        scrap.scale = 1.2;
        
        // bounce by 20px (10 on each side)
        CGFloat bounceScale = 20 / MAX(scrapSize.width, scrapSize.height);

        // animate the scrap dropping and bouncing on the page
        [UIView animateWithDuration:.2
                              delay:.1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // doesn't need to land exactly center. this way
                             // multiple imports of multiple photos won't all
                             // land exactly on top of each other. looks nicer.
                             CGPoint center = [visibleStackHolder peekSubview].center;
                             center.x += random() % 14 - 7;
                             center.y += random() % 14 - 7;
                             scrap.center = center;
                             [scrap setScale:(1-bounceScale) andRotation:RandomPhotoRotation];
                             scrap.alpha = .72;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:.1
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  [scrap setScale:1];
                                                  scrap.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished){
                                                  [topPage.scrapsOnPaperState showScrap:scrap];
                                                  [topPage saveToDisk];
                                              }];
                         }];
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotoImports by:@(1)];
        [[Mixpanel sharedInstance] track:kMPEventImportPhoto properties:@{kMPEventImportPropFileExt : [url fileExtension],
                                                                          kMPEventImportPropFileType : [url universalTypeID],
                                                                          kMPEventImportPropSource : kMPEventImportPropSourceApplication,
                                                                          kMPEventImportPropReferApp : sourceApplication}];
    } afterDelay:.15];
}

-(void) didProcessIncomingPDF:(MMPDF*)pdfDoc fromURL:(NSURL*)url fromApp:(NSString*)sourceApplication{
    if(pdfDoc.pageCount == 1){
        // create a UIImage from teh PDF and add it like normal above
    }else{
        
    }
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotoImports by:@(1)];
    [[Mixpanel sharedInstance] track:kMPEventImportPhoto properties:@{kMPEventImportPropFileExt : [url fileExtension],
                                                                      kMPEventImportPropFileType : [url universalTypeID],
                                                                      kMPEventImportPropSource : kMPEventImportPropSourceApplication,
                                                                      kMPEventImportPropPDFPageCount : @(pdfDoc.pageCount),
                                                                      kMPEventImportPropReferApp : sourceApplication}];
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

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotosTaken by:@(1)];
    [[Mixpanel sharedInstance] track:kMPEventTakePhoto];
    CGRect scrapRect = CGRectZero;
    scrapRect.origin = [self convertPoint:cameraView.layer.bounds.origin fromView:cameraView];
    scrapRect.size = cameraView.bounds.size;
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
    
    CGSize fullScale = img.size;
    if(fullScale.width >= fullScale.height && fullScale.width > maxDim){
        fullScale.height = fullScale.height / fullScale.width * maxDim;
        fullScale.width = maxDim;
    }else if(fullScale.height >= fullScale.width && fullScale.height > maxDim){
        fullScale.width = fullScale.width / fullScale.height * maxDim;
        fullScale.height = maxDim;
    }
    
    CGFloat startingScale = scrapRect.size.width / fullScale.width;
    
    UIImage* scrapBacking = [img resizedImage:CGSizeMake(ceilf(fullScale.width/2), ceilf(fullScale.height/2)) interpolationQuality:kCGInterpolationMedium];
    
    MMUndoablePaperView* topPage = [visibleStackHolder peekSubview];
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
    
    // add the background, and scale it so it fills the scrap
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:scrapBacking forScrapState:scrap.state];
    backgroundView.backgroundScale = scaleUpOfImage;
    [scrap setBackgroundView:backgroundView];

    // center the scrap on top of the camera view
    // so we can slide it onto the page
    scrap.center = [self convertPoint:CGPointMake(cameraView.bounds.size.width/2, cameraView.bounds.size.height/2) fromView:cameraView];
    scrap.rotation = cameraView.rotation;
    
    [imagePicker hide:YES];
    
    // hide the photo in the row
    cameraView.alpha = 0;
    
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
                                              cameraView.alpha = 1;
                                              [topPage.scrapsOnPaperState showScrap:scrap];
                                              [topPage addUndoItemForAddedScrap:scrap];
                                              [topPage saveToDisk];
                                          }];
                     }];
}

-(void) photoWasTapped:(ALAsset *)asset fromView:(MMBufferedImageView *)bufferedImage withRotation:(CGFloat)rotation fromContainer:(NSString *)containerDescription{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfPhotoImports by:@(1)];
    
    NSURL* assetURL = asset.defaultRepresentation.url;
    [[Mixpanel sharedInstance] track:kMPEventImportPhoto properties:@{ kMPEventImportPropFileExt : [assetURL fileExtension],
                                                                       kMPEventImportPropFileType : [assetURL universalTypeID],
                                                                       kMPEventImportPropSource: containerDescription}];
    
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
    
    MMUndoablePaperView* topPage = [visibleStackHolder peekSubview];
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
    
    // add the background, and scale it so it fills the scrap
    MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:scrapBacking forScrapState:scrap.state];
    backgroundView.backgroundScale = scaleUpOfImage;
    [scrap setBackgroundView:backgroundView];

    // move the scrap so that it covers the image that was just tapped.
    // then we'll animate it onto the page
    scrap.center = [self convertPoint:CGPointMake(bufferedImage.bounds.size.width/2, bufferedImage.bounds.size.height/2) fromView:bufferedImage];
    scrap.rotation = bufferedImage.rotation;
    
    // hide the picker, this'll slide it out
    // underneath our scrap
    [imagePicker hide:YES];
    
    // hide the photo in the row. this way the scrap
    // becomes the photo, and it doesn't seem to duplicate
    // as the image sidebar hides. the image in the sidebar
    // will reset after the sidebar is done hiding
    bufferedImage.alpha = 0;
    
    // bounce by 20px (10 on each side)
    CGFloat bounceScale = 20 / MAX(fullScale.width, fullScale.height);
    
    [UIView animateWithDuration:.2
                          delay:.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         scrap.center = [visibleStackHolder peekSubview].center;
                         [scrap setScale:(1+bounceScale) andRotation:scrap.rotation + RandomPhotoRotation];
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
                                              [topPage.scrapsOnPaperState showScrap:scrap];
                                              [topPage addUndoItemForAddedScrap:scrap];
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
    
    debug_NSLog(@"auto-lines: %d   pages: %d", numLines, (int) floor(numLines / strokesPerPage));
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
        [str appendFormat:@"%@ %d\n", NSStringFromClass([gesture class]), (int)st];
        if([gesture respondsToSelector:@selector(validTouches)]){
            [str appendFormat:@"   validTouches: %d\n", (int)[[gesture performSelector:@selector(validTouches)] count]];
        }
        if([gesture respondsToSelector:@selector(touches)]){
            [str appendFormat:@"   touches: %d\n", (int)[[gesture performSelector:@selector(touches)] count]];
        }
        if([gesture respondsToSelector:@selector(possibleTouches)]){
            [str appendFormat:@"   possibleTouches: %d\n", (int)[[gesture performSelector:@selector(possibleTouches)] count]];
        }
        if([gesture respondsToSelector:@selector(ignoredTouches)]){
            [str appendFormat:@"   ignoredTouches: %d\n", (int)[[gesture performSelector:@selector(ignoredTouches)] count]];
        }
        if([gesture respondsToSelector:@selector(paused)]){
            [str appendFormat:@"   paused: %d\n", [gesture performSelector:@selector(paused)] ? 1 : 0];
        }
        if([gesture respondsToSelector:@selector(scrap)]){
            [str appendFormat:@"   has scrap: %d\n", [gesture performSelector:@selector(scrap)] ? 1 : 0];
        }
    }
    [str appendFormat:@"velocity gesture sees: %d\n", [[MMTouchVelocityGestureRecognizer sharedInstace] numberOfActiveTouches]];
    [str appendFormat:@"pages being panned %d\n", (int)[setOfPagesBeingPanned count]];
    
    [str appendFormat:@"done\n"];
    
    for(MMScrapView* scrap in [[visibleStackHolder peekSubview] scrapsOnPaper]){
        [str appendFormat:@"scrap: %f %f\n", scrap.layer.anchorPoint.x, scrap.layer.anchorPoint.y];
    }

    BOOL visibleStackHasDisabledPages = NO;
    BOOL hiddenStackHasEnabledPages = NO;
    for(MMPaperView* page in visibleStackHolder.subviews){
        if(!page.areGesturesEnabled){
            visibleStackHasDisabledPages = YES;
        }
    }
    for(MMPaperView* page in hiddenStackHolder.subviews){
        if(page.areGesturesEnabled){
            hiddenStackHasEnabledPages = YES;
        }
    }
    
    
    [str appendFormat:@"top visible page is disabled? %i\n", ![visibleStackHolder peekSubview].areGesturesEnabled];
    [str appendFormat:@"visible stack has disabled? %i\n", visibleStackHasDisabledPages];
    [str appendFormat:@"hidden stack has enabled? %i\n", hiddenStackHasEnabledPages];

    
    return str;
}


-(void) timerDidFire:(NSTimer*)timer{
    debug_NSLog(@"%@", [self activeGestureSummary]);
}

-(void) drawLine{
    [[[visibleStackHolder peekSubview] drawableView] drawLongLine];
}

#pragma mark - Add Page

-(void) addPageButtonTapped:(UIButton*)_button{
    [self forceScrapToScrapContainerDuringGesture];
    [super addPageButtonTapped:_button];
}

-(void) shareButtonTapped:(UIButton*)_button{
    if([[visibleStackHolder peekSubview] hasEditsToSave]){
        wantsExport = [visibleStackHolder peekSubview];
    }else{
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        [composer setMailComposeDelegate:self];
        if([MFMailComposeViewController canSendMail]) {
            [composer setSubject:@"Quick sketch from Loose Leaf"];
            [composer setMessageBody:@"\n\n\n\nDrawn with Loose Leaf. http://getlooseleaf.com" isHTML:NO];
            [composer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            
            NSData *data = UIImagePNGRepresentation([visibleStackHolder peekSubview].scrappedImgViewImage);
            [composer addAttachmentData:data  mimeType:@"image/png" fileName:@"LooseLeaf.png"];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:composer animated:YES completion:nil];
        }
    }
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
            NSLog(@"forceScrapToScrapContainerDuringGesture");
        }
    }
    if(panAndPinchScrapGesture2.scrap && panAndPinchScrapGesture2.state != UIGestureRecognizerStateCancelled){
        if(![scrapContainer.subviews containsObject:panAndPinchScrapGesture2.scrap]){
            [scrapContainer addSubview:panAndPinchScrapGesture2.scrap];
            [self panAndScaleScrap:panAndPinchScrapGesture2];
            NSLog(@"forceScrapToScrapContainerDuringGesture");
        }
    }
}

-(void) isBezelingInLeftWithGesture:(MMBezelInGestureRecognizer*)bezelGesture{
    if(bezelGesture.subState != UIGestureRecognizerStatePossible &&
       bezelGesture.subState != UIGestureRecognizerStateFailed){
        [self forceScrapToScrapContainerDuringGesture];
        [super isBezelingInLeftWithGesture:bezelGesture];
    }
}

-(void) isBezelingInRightWithGesture:(MMBezelInGestureRecognizer *)bezelGesture{
    if(bezelGesture.subState != UIGestureRecognizerStatePossible &&
       bezelGesture.subState != UIGestureRecognizerStateFailed){
        [self forceScrapToScrapContainerDuringGesture];
        [super isBezelingInRightWithGesture:bezelGesture];
    }
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
        MMUndoablePaperView* pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
        if(![pageToDropScrap isEqual:[visibleStackHolder peekSubview]]){
            // if the page it should drop isn't the top visible page,
            // then add it to the scrap container view.
            if(![scrapContainer.subviews containsObject:scrap]){
                // just keep it in the scrap container
                [scrapContainer addSubview:scrap];
            }
        }else if(pageToDropScrap && [pageToDropScrap.scrapsOnPaperState isScrapVisible:scrap]){
            // only adjust for the page if the page
            // already has the scrap. otherwise we'll keep
            // the scrap in the container view and only drop
            // it onto a page once the gesture is complete.
            gesture.scrap.scale = scrapScaleInPage;
            gesture.scrap.center = scrapCenterInPage;
        }else if(pageToDropScrap && ![pageToDropScrap.scrapsOnPaperState isScrapVisible:scrap]){
            [self forceScrapToScrapContainerDuringGesture];
        }
        
        // only allow for shaking if:
        // 1. gesture is shaking
        // 2. there are other scraps on the page to re-order with, and
        // 3. we're not actively bezeling on a potentially different top page
        //    (since the bezel will pull the scrap to the scrapContainer anyways, there's
        //     no use adding an undo level for this shake)
        if(gesture.isShaking && [pageToDropScrap.scrapsOnPaper count] && ![fromLeftBezelGesture isActivelyBezeling] && ![fromRightBezelGesture isActivelyBezeling]){
            // if the gesture is shaking, then pull the scrap to the top if
            // it's not already. otherwise send it to the back
            if([pageToDropScrap isEqual:[[MMPageCacheManager sharedInstance] currentEditablePage]] &&
               ![pageToDropScrap.scrapsOnPaperState isScrapVisible:scrap]){
                // this happens when the user picks up a scrap
                // bezels / turns to another page while holding the scrap
                // and then shakes the scrap to re-order it on the new page

                // this page isn't allowed to steal another page's scrap,
                // so we need to clone it before passing it to the new page
                MMScrapView* clonedScrap = [self cloneScrap:gesture.scrap toPage:pageToDropScrap];
                // add the scrap to the bottom of the page
                [pageToDropScrap.scrapsOnPaperState showScrap:clonedScrap];
                [clonedScrap.superview insertSubview:clonedScrap atIndex:0];
                // remove the scrap from the original page
                [gesture.scrap removeFromSuperview];
                
                // add the undo items
                [gesture.startingPageForScrap addUndoItemForRemovedScrap:gesture.scrap withProperties:gesture.startingScrapProperties];
                [pageToDropScrap addUndoItemForAddedScrap:clonedScrap];
                
                // update the gesture to start working with the cloned scrap,
                // and make sure that this cloned scrap's anchor is at the
                // correct place so the swap is seamless
                [UIView setAnchorPoint:gesture.scrap.layer.anchorPoint forView:clonedScrap];
                gesture.scrap = clonedScrap;
                [clonedScrap setShouldShowShadow:YES];
                [clonedScrap setSelected:YES];
                
                // save the page we just dropped the scrap on
                [pageToDropScrap saveToDisk];
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
    if(gesture.scrap && (gesture.state == UIGestureRecognizerStateEnded ||
                         gesture.state == UIGestureRecognizerStateCancelled ||
                         ![gesture.validTouches count])){
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
        
        MMUndoablePaperView* pageToDropScrap = nil;
        if(gesture.didExitToBezel){
            shouldBezel = YES;
            // remove scrap undo item
        }else if([scrapsInContainer containsObject:gesture.scrap]){
            CGFloat scrapScaleInPage;
            CGPoint scrapCenterInPage;
            if(gesture.state == UIGestureRecognizerStateCancelled){
                pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
                if(pageToDropScrap == [visibleStackHolder peekSubview]){
                    // it would drop on the visible page, so just
                    // do that
                    [self scaledCenter:&scrapCenterInPage andScale:&scrapScaleInPage forScrap:gesture.scrap onPage:pageToDropScrap];
                }else{
                    // it wouldn't have dropped on the visible page, so
                    // bezel it instead
                    shouldBezel = YES;
                }
            }else{
                pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
            }
            if(pageToDropScrap){
                gesture.scrap.scale = scrapScaleInPage;
                gesture.scrap.center = scrapCenterInPage;
                
                if(pageToDropScrap != gesture.startingPageForScrap){
                    // make remove/add scrap undo items
                    // need to somehow save which page used to
                    // own this scrap
                    
                    // clone the scrap and add it to the
                    // page where it was dropped. this way, the
                    // original page can undo the move and get its
                    // own scrap back without adjusting the undo state
                    // of the page that the scrap was dropped on to.
                    //
                    // similarly, the page that had the scrap dropped onto
                    // it can undo the drop and it won't affect the page that
                    // the scrap came from
                    MMScrapView* clonedScrap = [self cloneScrap:gesture.scrap toPage:pageToDropScrap];
                    [pageToDropScrap.scrapsOnPaperState showScrap:clonedScrap];
                    // remove the scrap from the original page
                    [gesture.scrap removeFromSuperview];

                    // add the undo items
                    [gesture.startingPageForScrap addUndoItemForRemovedScrap:gesture.scrap withProperties:gesture.startingScrapProperties];
                    [pageToDropScrap addUndoItemForAddedScrap:clonedScrap];
                }else{
                    // make a move-scrap undo item.
                    // we don't need to add an 'add scrap' undo item,
                    // since this is the page that originated the scrap
                    if(![pageToDropScrap.scrapsOnPaperState isScrapVisible:gesture.scrap]){
                        [pageToDropScrap.scrapsOnPaperState showScrap:gesture.scrap];
                    }
                    [gesture.startingPageForScrap addUndoItemForScrap:gesture.scrap thatMovedFrom:gesture.startingScrapProperties to:[gesture.scrap propertiesDictionary]];
                }
                
                [pageToDropScrap saveToDisk];
            }else{
                // couldn't find a page to catch it
                shouldBezel = YES;
            }
        }else{
            // scrap stayed on page
            // make a move-scrap undo item
            [gesture.startingPageForScrap addUndoItemForScrap:gesture.scrap thatMovedFrom:gesture.startingScrapProperties to:[gesture.scrap propertiesDictionary]];
        }
        
        // save teh page that the scrap came from
        MMEditablePaperView* pageThatGaveUpScrap = gesture.startingPageForScrap;
        if((pageToDropScrap || shouldBezel) && pageThatGaveUpScrap != pageToDropScrap){
            [pageThatGaveUpScrap saveToDisk];
            [pageToDropScrap saveToDisk];
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
        NSDictionary* startingScrapProperties = gesture.startingScrapProperties;
        MMUndoablePaperView* startingPageForScrap = gesture.startingPageForScrap;
        
        [gesture giveUpScrap];
        
        if(shouldBezel){
            [startingPageForScrap addUndoItemForBezeledScrap:scrap withProperties:startingScrapProperties];
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
-(MMUndoablePaperView*) pageWouldDropScrap:(MMScrapView*)scrap atCenter:(CGPoint*)scrapCenterInPage andScale:(CGFloat*)scrapScaleInPage{
    MMUndoablePaperView* pageToDropScrap = nil;
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
    int indexNum = (int)[bezelStackHolder.subviews count] - 1;

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
            indexNum = (int)[(arrayOfArrayOfViews[arrayNum]) count] - 1;
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
        
        if(![[visibleStackHolder peekSubview].scrapsOnPaperState isScrapVisible:scrap]){
            // the scrap was dropped by the stretch gesture,
            // so just add it back to the top page
            [[visibleStackHolder peekSubview].scrapsOnPaperState showScrap:scrap];
            [[visibleStackHolder peekSubview] saveToDisk];
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
    debug_NSLog(@"%@ (%p) knows about:\n%@\n%@\n%@ ", prefix, gesture, validOut, possibleOut, ignoredOut);
}


// time to duplicate the scraps! it's been pulled into two pieces
-(void) endStretchBySplittingScrap:(MMScrapView*)scrap toTouches:(NSOrderedSet*)touches1 atNormalPoint:(CGPoint)np1
                     andTouches:(NSOrderedSet*)touches2  atNormalPoint:(CGPoint)np2{

    // save the gestures to local variables.
    // this will let us make sure the input scrap stays with its
    // current gesture, if any
    MMPanAndPinchScrapGestureRecognizer* panScrapGesture1 = panAndPinchScrapGesture;
    MMPanAndPinchScrapGestureRecognizer* panScrapGesture2 = panAndPinchScrapGesture2;

    if(panAndPinchScrapGesture2.scrap == scrap){
        // a gesture already owns that scrap, so let it keep it.
        // this will let the startingPageForScrap property
        // remain the same for the gesture, so the scrap won't
        // get accidentally assigned to the wrong page.
        //
        // to make sure everything still gets the right touches
        // at the right locations, i need to swap all inputs
        panScrapGesture1 = panAndPinchScrapGesture2;
        panScrapGesture2 = panAndPinchScrapGesture;
        NSOrderedSet* t = touches1;
        touches1 = touches2;
        touches2 = t;
        CGPoint tnp = np1;
        np1 = np2;
        np2 = tnp;
        NSLog(@"panAndPinchScrapGesture2 %p owned scrap %p", panAndPinchScrapGesture2, scrap);
    }else{
        NSLog(@"panAndPinchScrapGesture %p owned scrap %p", panAndPinchScrapGesture, scrap);
    }
    
    [self logOutputGestureTouchOwnership:@"before gesture 1" gesture:panScrapGesture1];
    [self logOutputGestureTouchOwnership:@"before gesture 2" gesture:panScrapGesture2];
    
    [panScrapGesture1 relinquishOwnershipOfTouches:[touches2 set]];
    [panScrapGesture2 relinquishOwnershipOfTouches:[touches1 set]];
    
    [self logOutputGestureTouchOwnership:@"relenquished gesture 1" gesture:panScrapGesture1];
    [self logOutputGestureTouchOwnership:@"relenquished gesture 2" gesture:panScrapGesture2];
    
    [self sendStretchedScrap:scrap toPanGesture:panScrapGesture1 withTouches:[touches1 array] withAnchor:np1];
    
    [self logOutputGestureTouchOwnership:@"after 1 set gesture 1" gesture:panScrapGesture1];
    [self logOutputGestureTouchOwnership:@"after 1 set gesture 2" gesture:panScrapGesture2];


    // next, add the new scrap to the same page as the stretched scrap
    MMUndoablePaperView* page = [visibleStackHolder peekSubview];
    MMScrapView* clonedScrap = [self cloneScrap:scrap toPage:page];
    [page.scrapsOnPaperState showScrap:clonedScrap];
    
    // move it to the new gesture location under it's scrap
    CGPoint p1 = [[touches2 objectAtIndex:0] locationInView:self];
    CGPoint p2 = [[touches2 objectAtIndex:1] locationInView:self];
    clonedScrap.center = AveragePoints(p1, p2);

    [page addUndoItemForAddedScrap:clonedScrap];
    
    // hand the cloned scrap to the pan scrap gesture
    panScrapGesture2.scrap = clonedScrap;

    // now that the scrap is where it should be,
    // and contains its background, etc, then
    // save everything
    [page saveToDisk];
    
    // time to reset the gesture for the cloned scrap
    // now the scrap is in the right place, so hand it off to the pan gesture
    [self sendStretchedScrap:clonedScrap toPanGesture:panScrapGesture2 withTouches:[touches2 array] withAnchor:np2];
    
    [self logOutputGestureTouchOwnership:@"after 2 set gesture 1" gesture:panScrapGesture1];
    [self logOutputGestureTouchOwnership:@"after 2 set gesture 2" gesture:panScrapGesture2];

    
    if(!panScrapGesture1.scrap || !panScrapGesture2.scrap){
        debug_NSLog(@"what: ending scrap gesture w/o holding scrap");
        // sanity checks.
        // we should never enter here
        if([panScrapGesture1.initialTouchVector isEqual:panScrapGesture2.initialTouchVector]){
            debug_NSLog(@"what");
        }
        
        if(scrap.scale != clonedScrap.scale ||
           scrap.rotation != clonedScrap.rotation){
            debug_NSLog(@"what");
        }
        
        debug_NSLog(@"success? %d %p,  %d %p", (int)[panScrapGesture1.validTouches count], panScrapGesture1.scrap,
              (int)[panScrapGesture2.validTouches count], panScrapGesture2.scrap);

        if([panScrapGesture1.validTouches count] < 2){
            [self logOutputGestureTouchOwnership:@"gesture 1 failed gesture 1" gesture:panScrapGesture1];
            [self logOutputGestureTouchOwnership:@"gesture 1 failed gesture 2" gesture:panScrapGesture2];
        }
        if([panScrapGesture2.validTouches count] < 2){
            [self logOutputGestureTouchOwnership:@"gesture 2 failed gesture 1" gesture:panScrapGesture1];
            [self logOutputGestureTouchOwnership:@"gesture 2 failed gesture 2" gesture:panScrapGesture2];
        }
        @throw [NSException exceptionWithName:@"DroppedSplitScrap" reason:@"split scrap was dropped by pan gestures" userInfo:nil];
    }
}


#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

-(NSArray*) scrapsToPan{
    if([fromLeftBezelGesture isActivelyBezeling]){
        return [[[bezelStackHolder peekSubview] scrapsOnPaper] arrayByAddingObjectsFromArray:scrapContainer.subviews];
    }
    return [[[visibleStackHolder peekSubview] scrapsOnPaper] arrayByAddingObjectsFromArray:scrapContainer.subviews];
}

-(BOOL) panScrapRequiresLongPress{
    return rulerButton.selected;
}

-(BOOL) isAllowedToPan{
    if([fromRightBezelGesture isActivelyBezeling] || [fromLeftBezelGesture isActivelyBezeling]){
        // not allowed to pan a page if we're
        // bezeling
        return NO;
    }
    return handButton.selected;
}

-(BOOL) allowsHoldingScrapsWithTouch:(UITouch*)touch{
    if([fromLeftBezelGesture isActivelyBezeling]){
        return [touch locationInView:bezelStackHolder].x > 0;
    }else if([fromRightBezelGesture isActivelyBezeling]){
        return [touch locationInView:bezelStackHolder].x < 0;
    }
    return YES;
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
        MMPaperView* pageHoldingScrap = [visibleStackHolder peekSubview];
        if([fromLeftBezelGesture isActivelyBezeling]){
            pageHoldingScrap = [bezelStackHolder peekSubview];
        }
        CGFloat pageScale = pageHoldingScrap.scale;
        // because the page uses a transform to scale itself, the scrap center will always
        // be in page scale = 1.0 form. if the user picks up a scrap while also scaling the page,
        // then we need to transform that coordinate into the visible scale of the zoomed page.
        scrapCenter = CGPointApplyAffineTransform(scrapCenter, CGAffineTransformMakeScale(pageScale, pageScale));
        // now that the coordinate is in the visible scale, we can convert that directly to the
        // scapContainer's coodinate system
        return [pageHoldingScrap convertPoint:scrapCenter toView:scrapContainer];
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

-(void) finishedPanningAndScalingPage:(MMPaperView *)page intoBezel:(MMBezelDirection)direction fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    [super finishedPanningAndScalingPage:page intoBezel:direction fromFrame:fromFrame toFrame:toFrame];
    [self panAndScaleScrap:panAndPinchScrapGesture];
    [self panAndScaleScrap:panAndPinchScrapGesture2];
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

-(MMScrapSidebarContainerView*) bezelContainerView{
    return bezelScrapContainer;
}


#pragma mark - MMGestureTouchOwnershipDelegate

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [super ownershipOfTouches:touches isGesture:gesture];
    if([gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]] ||
       [gesture isKindOfClass:[MMStretchScrapGestureRecognizer class]]){
        // only notify of our own gestures, super will handle its own
        [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
    }
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
    [panAndPinchScrapGesture2 ownershipOfTouches:touches isGesture:gesture];
    [stretchScrapGesture ownershipOfTouches:touches isGesture:gesture];
}

#pragma mark - Page Loading and Unloading

-(void) willChangeTopPageTo:(MMPaperView *)page{
    [super willChangeTopPageTo:page];
    [[[MMPageCacheManager sharedInstance] currentEditablePage] saveToDisk];
}


#pragma mark - Long Press Scrap

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
    [bezelScrapContainer saveScrapContainerToDisk];
}

// returns the page that the scrap was added to
-(MMUndoablePaperView*) didAddScrapBackToPage:(MMScrapView *)scrap atIndex:(NSUInteger)index{
    // first, find the page to add the scrap to.
    // this will check visible + bezelled pages to see
    // which page should get the scrap, and it'll tell us
    // the center/scale to use
    CGPoint center;
    CGFloat scale;
    MMUndoablePaperView* page = [self pageWouldDropScrap:scrap atCenter:&center andScale:&scale];
    
    [scrap blockToFireWhenStateLoads:^{
        CheckMainThread;
        // we're only allowed to add scraps to a page
        // when their state is loaded, so make sure
        // we have their state loading
        MMScrapView* scrapToAddToPage = scrap;
        if(scrap.state.scrapsOnPaperState != page.scrapsOnPaperState){
            MMScrapView* oldScrap = scrap;
            [scrapContainer addSubview:oldScrap];
            scrapToAddToPage = [self cloneScrap:scrap toPage:page];
            [oldScrap removeFromSuperview];
        }
        // ok, done, just set it
        if(index == NSNotFound){
            [page.scrapsOnPaperState showScrap:scrapToAddToPage];
        }else{
            [page.scrapsOnPaperState showScrap:scrapToAddToPage atIndex:index];
        }
        scrapToAddToPage.center = center;
        scrapToAddToPage.scale = scale;
        [page saveToDisk];
        [bezelScrapContainer saveScrapContainerToDisk];
    }];
    return page;
}

-(MMScrappedPaperView*) pageForUUID:(NSString*)uuid{
    NSMutableArray* allPages = [NSMutableArray arrayWithArray:visibleStackHolder.subviews];
    [allPages addObjectsFromArray:[bezelStackHolder.subviews copy]];
    [allPages addObjectsFromArray:[hiddenStackHolder.subviews copy]];
    return [[allPages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[evaluatedObject uuid] isEqualToString:uuid];
    }]] firstObject];
}

-(CGPoint) positionOnScreenToScaleScrapTo:(MMScrapView*)scrap{
    return [visibleStackHolder center];
}

-(CGFloat) scaleOnScreenToScaleScrapTo:(MMScrapView*)scrap givenOriginalScale:(CGFloat)originalScale{
    return originalScale * [visibleStackHolder peekSubview].scale;
}



#pragma mark - List View

-(void) isBeginningToScaleReallySmall:(MMPaperView*)page{
    if(panAndPinchScrapGesture.scrap){
        [panAndPinchScrapGesture cancel];
    }
    if(panAndPinchScrapGesture2.scrap){
        [panAndPinchScrapGesture2 cancel];
    }
    [panAndPinchScrapGesture setEnabled:NO];
    [panAndPinchScrapGesture2 setEnabled:NO];
    [super isBeginningToScaleReallySmall:page];
}

-(void) cancelledScalingReallySmall:(MMPaperView *)page{
    [panAndPinchScrapGesture setEnabled:YES];
    [panAndPinchScrapGesture2 setEnabled:YES];
    [super cancelledScalingReallySmall:page];
}


-(void) finishedScalingReallySmall:(MMPaperView *)page{
    if(panAndPinchScrapGesture.scrap){
        [panAndPinchScrapGesture cancel];
    }
    if(panAndPinchScrapGesture2.scrap){
        [panAndPinchScrapGesture2 cancel];
    }
    [panAndPinchScrapGesture setEnabled:NO];
    [panAndPinchScrapGesture2 setEnabled:NO];
    [super finishedScalingReallySmall:page];
}

-(void) finishedScalingBackToPageView:(MMPaperView *)page{
    [panAndPinchScrapGesture setEnabled:YES];
    [panAndPinchScrapGesture2 setEnabled:YES];
    [super finishedScalingBackToPageView:page];
}


#pragma mark - MMStretchScrapGestureRecognizerDelegate

// return all touches that fall within the input scrap's boundary
// and don't fall within any scrap above the input scrap
-(NSSet*) setOfTouchesFrom:(NSOrderedSet *)touches inScrap:(MMScrapView *)scrap{
    return nil;
}

#pragma mark - MMRotationManagerDelegate

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient{
    [imagePicker updatePhotoRotation];
}


#pragma mark = Saving and Editing

-(void) didSavePage:(MMPaperView*)page{
//    NSLog(@"did save page: %@", page.uuid);
    [super didSavePage:page];
    if(wantsExport == page){
        wantsExport = nil;
        [self shareButtonTapped:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSString* strResult;
    if(result == MFMailComposeResultCancelled){
        strResult = @"Cancelled";
    }else if(result == MFMailComposeResultFailed){
        strResult = @"Failed";
    }else if(result == MFMailComposeResultSaved){
        strResult = @"Saved";
    }else if(result == MFMailComposeResultSent){
        strResult = @"Sent";
    }
    if(result == MFMailComposeResultSent || result == MFMailComposeResultSaved){
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
    }
    [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Email",
                                                                 kMPEventExportPropResult : strResult}];
    

    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Clone Scrap

/**
 * this will clone a scrap and also clone it's contents
 * the scrap to be cloned must be in our scrapContainer,
 * and the cloned scrap will be put in the scrapContainer
 * as well, exactly overlapping it
 *
 * the new cloned scrap is allowed to be added to our
 * scrap container, its just not allowed to be added to
 * any pages scrap container besides its own
 */
-(MMScrapView*) cloneScrap:(MMScrapView*)scrap toPage:(MMScrappedPaperView*)page{
    CheckMainThread;
    
    if(![scrapContainer.subviews containsObject:scrap]){
        @throw [NSException exceptionWithName:@"CloneScrapException" reason:@"Page asked to clone scrap and doesn't own it" userInfo:nil];
    }
    // we need to send in scale 1.0 because the *path* scale we're sending in is for the 1.0 scaled path.
    // if we sent the scale into this method, it would assume that the input path was *already at* the input
    // scale, so it would transform the path to a 1.0 scale before adding the scrap. this would result in incorrect
    // resolution for the new scrap. so set the rotation to make sure we're getting the smallest bounding
    // box, and we'll set the scrap's scale to match after we add it to the page.
    
    BOOL needsStateLoading = ![page.scrapsOnPaperState isStateLoaded];
    __block MMScrapView* clonedScrap = nil;
    
    void(^block)() = ^{
        clonedScrap = [page.scrapsOnPaperState addScrapWithPath:[scrap.bezierPath copy] andRotation:scrap.rotation andScale:1.0];
        clonedScrap.scale = scrap.scale;
        [scrapContainer addSubview:clonedScrap];
        
        // next match it's location exactly on top of the original scrap:
        [UIView setAnchorPoint:scrap.layer.anchorPoint forView:clonedScrap];
        clonedScrap.center = scrap.center;
        
        // next, clone the contents onto the new scrap. at this point i have a duplicate scrap
        // but it's in the wrong place.
        [clonedScrap stampContentsFrom:scrap.state.drawableView];
        
        // clone background contents too
        [clonedScrap setBackgroundView:[scrap.backgroundView duplicateFor:clonedScrap.state]];
        
        // set the scrap anchor to its center
        [UIView setAnchorPoint:CGPointMake(.5, .5) forView:clonedScrap];
        
//        NSLog(@"clone scrap %@ into %@", scrap.uuid, clonedScrap.uuid);
    };
    
    if(needsStateLoading){
        [page performBlockForUnloadedScrapStateSynchronously:block];
    }else{
        block();
    }
    
    return clonedScrap;
}


#pragma mark - Hit Test

// MMEditablePaperStackView calls this method to check
// if the sidebar buttons should take priority over anything else
-(BOOL) shouldPrioritizeSidebarButtonsForTaps{
    return ![imagePicker isVisible];
}

#pragma mark - Check for Active Gestures

-(BOOL) isActivelyGesturing{
    return [super isActivelyGesturing] || panAndPinchScrapGesture.scrap || panAndPinchScrapGesture2.scrap || stretchScrapGesture.scrap;
}

@end

//
//  Contants.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#ifndef Paper_Stack_Contants_h
#define Paper_Stack_Contants_h

#import "AuthConstants.h"
#import "UIDevice+PPI.h"

static inline CGRect _CGSizeAspectFillFit(CGSize sizeToScale, CGSize sizeToFill, BOOL fill) {
    CGFloat horizontalRatio = sizeToFill.width / sizeToScale.width;
    CGFloat verticalRatio = sizeToFill.height / sizeToScale.height;
    CGFloat ratio;
    if (fill) {
        ratio = MAX(horizontalRatio, verticalRatio); //AspectFill
    } else {
        ratio = MIN(horizontalRatio, verticalRatio); //AspectFill
    }

    CGSize scaledSize = CGSizeMake(sizeToScale.width * ratio, sizeToScale.height * ratio);

    return CGRectMake((sizeToFill.width - scaledSize.width) / 2, (sizeToFill.height - scaledSize.height) / 2, scaledSize.width, scaledSize.height);
}

#define CGRectResizeBy(rect, dw, dh) CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + dw, rect.size.height + dh)
#define CGRectGetMidPoint(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define CGRectFromSize(size) CGRectMake(0, 0, size.width, size.height)
#define CGRectWithHeight(rect, height) CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height)
#define CGSizeMaxDim(size) MAX((size).width, (size).height)
#define CGSizeSwap(size) CGSizeMake((size).height, (size).width)
#define CGPointSwap(point) CGPointMake((point).y, (point).x)
#define CGRectSquare(size) CGRectMake(0, 0, size, size)
#define CGPointScale(point, scale) CGPointMake(point.x*(scale), point.y*(scale))
#define CGSizeScale(size, scale) CGSizeMake(size.width*(scale), size.height*(scale))
#define CGRectScale(rect, scale) CGRectMake(rect.origin.x*(scale), rect.origin.y*(scale), rect.size.width*(scale), rect.size.height*(scale))
#define CGRectSwap(rect) CGRectMake((rect).origin.y, (rect).origin.x, (rect).size.height, (rect).size.width)
#define CGSizeFill(sizeToScale, sizeToFill) _CGSizeAspectFillFit(sizeToScale, sizeToFill, YES)
#define CGSizeFit(sizeToScale, sizeToFill) _CGSizeAspectFillFit(sizeToScale, sizeToFill, NO)
#define CGPointTranslate(point, translatex, translatey) CGPointMake((point).x + (translatex), (point).y + (translatey))
#define CGRectTranslate(rect, translatex, translatey) CGRectMake((rect).origin.x + (translatex), (rect).origin.y + (translatey), (rect).size.width, (rect).size.height)

#define UIViewAutoresizingFlexibleAllMargins (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)

#define kURLAddedToDirectoryKey (&NSURLAddedToDirectoryDateKey ? NSURLAddedToDirectoryDateKey : NSURLCreationDateKey)

#define dispatch_get_background_queue() dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define CheckAnyThreadExcept(__THREAD_CHECK__)                                                                                                                                                          \
    {                                                                                                                                                                                                   \
        if (__THREAD_CHECK__) {                                                                                                                                                                         \
            @throw [NSException exceptionWithName:@"InconsistentQueueException" reason:[NSString stringWithFormat:@"Must execute %@ in an approved thread.", NSStringFromSelector(_cmd)] userInfo:nil]; \
        }                                                                                                                                                                                               \
    }

#define CheckThreadMatches(__THREAD_CHECK__)                                                                                                                                                            \
    {                                                                                                                                                                                                   \
        if (!(__THREAD_CHECK__)) {                                                                                                                                                                      \
            @throw [NSException exceptionWithName:@"InconsistentQueueException" reason:[NSString stringWithFormat:@"Must execute %@ in an approved thread.", NSStringFromSelector(_cmd)] userInfo:nil]; \
        }                                                                                                                                                                                               \
    }

#ifdef DEBUG
//#define DebugLog(__FORMAT__, ...)
#define DebugLog(__FORMAT__, ...) NSLog(__FORMAT__, ##__VA_ARGS__)
#else
#define DebugLog(__FORMAT__, ...)
#endif

#define SuppressPerformSelectorLeakWarning(Stuff)                               \
    do {                                                                        \
        _Pragma("clang diagnostic push")                                        \
            _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
                Stuff;                                                          \
        _Pragma("clang diagnostic pop")                                         \
    } while (0)

#define SIGN(__var__) (__var__ / ABS(__var__))

#define kAbstractMethodException [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]

#define kAnimationDelay 0.05

// Tutorial Notifications
#define kTutorialStartedNotification @"kTutorialStartedNotification"
#define kTutorialStepCompleteNotification @"kTutorialStepCompleteNotification"
#define kTutorialClosedNotification @"kTutorialClosedNotification"


// Display Assets
#define kDisplayAssetThumbnailGenerated @"kDisplayAssetThumbnailGenerated"
#define kInboxItemThumbnailGenerated @"kInboxItemThumbnailGenerated"
#define kBounceWidth 10.0


// Ruler
#define kWidthOfRuler 70
#define kRulerPinchBuffer 40
#define kRulerSnapAngle M_PI / 45.0


// List View
#define kNumberOfColumnsInListView 4
#define kListPageZoom (1.0 / (kNumberOfColumnsInListView + 1.0))

// List View Gesture
#define kZoomToListPageZoom .4
#define kMinPageZoom .8
#define kMaxPageZoom 2.0
#define kMaxPageResolution 1.5

// Page View
#define kMaxButtonsInBezelSidebar 6
#define kGutterWidthToDragPages 500
#define kFingerWidth 40
#define kFilteringFactor 0.2
#define kStartOfSidebar 310
#define kWidthOfSidebarButton 60.0
#define kWidthOfSidebarButtonBuffer 10
#define kWidthOfSidebar 80
#define kHeightOfImportTypeButton 80.0
#define kHeightOfRotationTypeButton 50.0
#define kMinScaleDelta .0
#define kShadowDepth 7
#define kShadowBend 3
#define kBezelInGestureWidth 40
#define kUndoLimit 10 // TODO: make sure this defines the jot undo level
#define kMaxButtonBounceHeight .4
#define kMinButtonBounceHeight -.2

// User Defaults

#define kFirstKnownVersion @"kFirstKnownVersion"
#define kLastOpenedVersion @"kLastOpenedVersion"
#define kImportAsPagePreferenceDefault @"importAsPagePreferenceDefault"
#define kExportAsPDFPreferenceDefault @"exportAsPDFPreferenceDefault"
#define kHasEverImportedAPage @"hasEverImportedAPage"
#define kMixpanelUUID @"mixpanel_uuid"
#define kSelectedBrush @"selectedBrush"
#define kBrushPencil @"pencil"
#define kBrushHighlighter @"highlighter"
#define kBrushMarker @"marker"
#define kMarkerColor @"markerColor"
#define kPencilColor @"pencilColor"
#define kHighlighterColor @"highlighterColor"
#define kHasEverCollapsedToShowAllStacks @"kHasEverCollapsedToShowAllStacks"
#define kDefaultPaperBackgroundStyle @"ruledOrGridBackgroundView"

#define kIsShowingListView @"ShowingListView" // old. use kCurrentViewMode instead.

#define kCurrentViewMode @"CurrentViewMode"
#define kViewModeList @"kViewModeList"
#define kViewModePage @"kViewModePage"
#define kViewModeCollapsed @"kViewModeCollapsed"

#define kCurrentStack @"CurrentStack"

// Camera
#define kCameraMargin 10
#define kCameraPositionUserDefaultKey @"com.milestonemade.preferredCameraPosition"

// Scraps
#define kScrapShadowBufferSize 4

// track social sharing availability
#define kMPShareStatusAvailable @"Available"
#define kMPShareStatusUnavailable @"Unavailable"
#define kMPShareStatusUnknown @"Unknown"

#define kMPShareStatusFacebook @"Share Status: Facebook"
#define kMPShareStatusTwitter @"Share Status: Twitter"
#define kMPShareStatusEmail @"Share Status: Email"
#define kMPShareStatusSMS @"Share Status: SMS"
#define kMPShareStatusTencentWeibo @"Share Status: Tencent Weibo"
#define kMPShareStatusSinaWeibo @"Share Status: Sina Weibo"

// MixPanel People Properties
#define kMPiPadModel @"iPad Model"
#define kMPStatScissorSegments @"Stat: Scissor Segment Count"
#define kMPStatScrapPathSegments @"Stat: Scrap Segment Count"
#define kMPStatSegmentTestCount @"Stat: Clipping Test Count"
#define kMPStatSegmentCompareCount @"Stat: Clipping Compare Count"
#define kMPPreferredLanguage @"Language"
#define kMPPreferredPaper @"Paper Style"
#define kMPID @"Mixpanel ID"
#define kMPScreenScale @"Screen Scale"
#define kMPDurationAppOpen @"Duration App Open"
#define kMPNumberOfPages @"Number of Pages"
#define kMPFirstLaunchDate @"Date of First Launch"
#define kMPNumberOfScraps @"Number of Scraps"
#define kMPHasBookTurnedPage @"Has Ever Turned Page"
#define kMPHasReorderedPage @"Has Ever Reordered Page"
#define kMPHasAddedPage @"Has Ever Added Page"
#define kMPHasAddedStack @"Has Ever Added Stack"
#define kMPNumberOfPenUses @"Number of Pen Uses"
#define kMPNumberOfEraserUses @"Number of Eraser Uses"
#define kMPNumberOfScissorUses @"Number of Scissor Uses"
#define kMPNumberOfRulerUses @"Number of Ruler Uses"
#define kMPNumberOfImports @"Number of Imports"
#define kMPNumberOfPhotoImports @"Number of Photo Imports" // import existing photo
#define kMPNumberOfPhotosTaken @"Number of Photos Taken" // take new photo with camera
#define kMPNumberOfExports @"Number of Exports"
#define kMPNumberOfOpenInExports @"Number of Open In Exports"
#define kMPNumberOfSocialExports @"Number of Social Media Exports"
#define kMPHasZoomedToList @"Has Zoomed Out to List"
#define kMPHasZoomedToPage @"Has Zoomed Into Page"
#define kMPHasDeletedPage @"Has Deleted Page"
#define kMPHasDeletedStack @"Has Deleted Stack"
#define kMPHasShakeToReorder @"Has Shaken Scrap"
#define kMPHasBezelledScrap @"Has Bezelled Scrap"
#define kMPNumberOfLaunches @"Number Of Launches"
#define kMPNumberOfResumes @"Number Of Resumes"
#define kMPNumberOfCrashes @"Number of Crashes"
#define kMPNumberOfMemoryCrashes @"Number of Mem Crashes"
#define kMPNumberOfDuplicatePages @"Duplicate Pages Found"
#define kMPDistanceDrawn @"Distance Drawn (m)"
#define kMPDistanceErased @"Distance Erased (m)"
#define kMPNumberOfInvites @"Number of Invites"
#define kMPNumberOfClippingExceptions @"Bezier Clip Exceptions"
#define kMPFailedRotationReading @"Failed Rotation Reading"
#define kMPEmailAddressField @"$email"
#define kMPPushEnabled @"Push Enabled"

#define kMPNumberOfHappyUpgrades @"Number of Happy Upgrades"
#define kMPNumberOfSadUpgrades @"Number of Sad Upgrades"
#define kMPUpgradeFeedback @"Upgrade Feedback"
#define kMPUpgradeFeedbackResult @"Feedback"
#define kMPUpgradeAppStoreReview @"App Store Review"
#define kMPUpgradeFeedbackReply @"Text Reply"

// tutorial
#define kMPHasFinishedTutorial @"Has Finished Tutorial"
#define kHasSignedUpForNewsletter @"kHasSignedUpForNewsletter"
#define kPendingEmailToSubscribe @"kPendingEmailToSubscribe"
#define kHasIgnoredNewsletter @"kHasIgnoredNewsletter"
#define kMPDurationWatchingTutorial @"Duration Watching Tutorial"
#define kMPDidBackgroundDuringTutorial @"Did Background During Tutorial"
#define kMPBackgroundDuringTutorial @"Background During Tutorial"
#define kCurrentTutorialStep @"kCurrentTutorialStep"
#define kMPNewsletterStatus @"Signed Up For Newsletter"
#define kMPNewsletterResponse @"Newsletter Response"
#define kMPTwitterFollow @"Followed on Twitter"

// invite properties
#define kMPEventInvite @"Invite Friend"
#define kMPEventInvitePropDestination @"Invite Destination"
#define kMPEventInvitePropResult @"Invite Result"

// MixPanel Error Events
#define kMPEventMemoryWarning @"Memory Warning"
#define kMPEventCrash @"Crash Report"
#define kMPEventCrashAverted @"Crash Averted"
#define kMPEventGestureBug @"Gesture Bug"

// MixPanel Events Properties
#define kMPNewsletterSignupAttemptEvent @"Submit Email Attempt"
#define kMPNewsletterSignupSuccessEvent @"Submit Email Success"
#define kMPNewsletterSignupFailedEvent @"Submit Email Failed"
#define kMPEventLaunch @"App Launch"
#define kMPEventResume @"App Resume"
#define kMPEventResign @"App Resign"
#define kMPEventActiveSession @"Active Session"
#define kMPEventTakePhoto @"Take Photo"
#define kMPEventImportPhoto @"Import Photo"
#define kMPEventImportPage @"Import Page"
#define kMPEventImportStack @"Import Stack"
#define kMPEventImportDuration @"Import Duration (s)"
#define kMPEventImportPhotoFailed @"Import Photo Failed"
#define kMPEventExport @"Export Page"
#define kMPEventClonePage @"Clone Page"
#define kMPEventCloneScrap @"Clone Scrap"

#define kMPNewsletterResponseSubscribed @"Subscribed to Newsletter"

#define kMPEventExportPropDestination @"Export Destination"
#define kMPEventExportPropResult @"Export Result"
#define kMPEventExportPropReason @"Export Result Reason"
#define kMPEventImportPropResult @"Import Result"
#define kMPEventImportPropFileExt @"File Extension"
#define kMPEventImportPropFileType @"File Type"
#define kMPEventImportPropReferApp @"Referring App"
#define kMPEventImportPropSource @"Import Source"
#define kMPEventImportPropPDFPageCount @"PDF Page Count"
#define kMPEventImportPropSourceApplication @"Application"
#define kMPEventImportPropScrapCount @"File Extension"
#define kMPEventImportPropVisibleScrapCount @"File Type"
#define kMPEventImportInvalidZipErrorCode -1
#define kMPEventImportMissingZipErrorCode -2

// MixPanel Error Tracking
#define kMPPathIterationException @"PathIterationException"


// photo album
#define kMaxPhotoRotationInDegrees 20
#define kThumbnailMaxDim (100 * [[UIScreen mainScreen] scale])
#define kPhotoImportMaxDim [UIDevice advisedMaxImportDim]
#define kPDFImportMaxDim [UIDevice advisedMaxImportDim]
#define kMaxScrapImportSizeOnPageFromBounce 800

// page cache manager
#define kPageCacheManagerHasLoadedAnyPage @"PageCacheManagerLoadedFirstPage"

#define RandomPhotoRotation(a) (^float(NSInteger b) {                                                              \
    srand((unsigned)b);                                                                                            \
    float output = ((float)(rand() % kMaxPhotoRotationInDegrees - kMaxPhotoRotationInDegrees / 2)) / 360.0 * M_PI; \
    srand((unsigned)time(NULL));                                                                                   \
    return output;                                                                                                 \
})(a)

#define RandomCollapsedPageRotation(a) (^float(NSInteger b) {    \
    srand((unsigned)b);                                          \
    float output = ((float)(rand() % 100 / 100.0 * .05 - .025)); \
    srand((unsigned)time(NULL));                                 \
    return output;                                               \
})(a)

#define RandomMod(a, b) (^float(NSInteger seed, int mod) { \
    srand((unsigned)seed);                                 \
    int output = (rand() % mod);                           \
    srand((unsigned)time(NULL));                           \
    return output;                                         \
})(a, b)

// cache sizes
#define kMMLoadImageCacheSize 10
#define kMMPageCacheManagerSize 1

#ifdef __cplusplus
extern "C" {
#endif

void CGContextSaveThenRestoreForBlock(CGContextRef __nonnull context, void (^__nonnull block)());

CGFloat DistanceBetweenTwoPoints(CGPoint point1, CGPoint point2);

CGFloat SquaredDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2);

CGPoint NormalizePointTo(CGPoint point1, CGSize size);

CGPoint DenormalizePointTo(CGPoint point1, CGSize size);

CGPoint AveragePoints(CGPoint point1, CGPoint point2);

#ifdef __cplusplus
}
#endif


enum {
    MMBezelDirectionNone = 0,
    MMBezelDirectionRight = 1 << 0,
    MMBezelDirectionLeft = 1 << 1,
    MMBezelDirectionUp = 1 << 2,
    MMBezelDirectionDown = 1 << 3
};
typedef NSUInteger MMBezelDirection;

enum {
    MMScaleDirectionNone = 0,
    MMScaleDirectionLarger = 1 << 0,
    MMScaleDirectionSmaller = 1 << 1
};
typedef NSUInteger MMBezelScaleDirection;


#ifdef __cplusplus
extern "C" {
#endif

typedef struct Quadrilateral {
    CGPoint upperLeft;
    CGPoint upperRight;
    CGPoint lowerRight;
    CGPoint lowerLeft;
} Quadrilateral;

#ifdef __cplusplus
} // extern "C"
#endif


#pragma mark - Math Interpolation Helpers

#ifdef __cplusplus
extern "C" {
#endif

// interpolate between min/max with 0<=t<=1
CGFloat logTransform(CGFloat min, CGFloat max, CGFloat t);

CGFloat sqrtTransform(CGFloat min, CGFloat max, CGFloat t);

CGFloat sqTransform(CGFloat min, CGFloat max, CGFloat t);

#ifdef __cplusplus
} // extern "C"

#endif


#endif

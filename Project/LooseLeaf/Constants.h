//
//  Contants.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#ifndef Paper_Stack_Contants_h
#define Paper_Stack_Contants_h


#define FACEBOOK_APP_ID @"YOUR_FACEBOOK_APP_ID"

#ifdef DEBUG
#define MIXPANEL_TOKEN @"YOUR_DEBUG_MIXPANEL_TOKEN"
#else
#define MIXPANEL_TOKEN @"YOUR_PROD_MIXPANEL_TOKEN"
#endif

#define dispatch_get_background_queue() dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define CheckAnyThreadExcept(__THREAD_CHECK__) {if(__THREAD_CHECK__){ @throw [NSException exceptionWithName:@"InconsistentQueueException" reason:[NSString stringWithFormat:@"Must execute %@ in an approved thread.", NSStringFromSelector(_cmd)] userInfo:nil]; }}

#define CheckThreadMatches(__THREAD_CHECK__) {if(!(__THREAD_CHECK__)){ @throw [NSException exceptionWithName:@"InconsistentQueueException" reason:[NSString stringWithFormat:@"Must execute %@ in an approved thread.", NSStringFromSelector(_cmd)] userInfo:nil]; }}

#ifdef DEBUG
//#define DebugLog(__FORMAT__, ...)
#define DebugLog(__FORMAT__, ...) NSLog(__FORMAT__, ## __VA_ARGS__)
#else
#define DebugLog(__FORMAT__, ...)
#endif

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define SIGN(__var__) (__var__ / ABS(__var__))

#define kAbstractMethodException [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]

#define kTestflightAppToken @"7cad2371-d0e0-4524-a833-dbc6cbc7a870"

#define kAnimationDelay 0.05

// CloudKit Import
#define kCloudKitMaxVisibleImports 5

// Imgur
#define kImgurClientID @"84d82da68fd2438"
#define kImgurClientSecret @"9d527186fee2a9f9e7af7f5e9fbbab334a1ac1ce"
#define kMashapeClientID @"YOUR_MASHAPE_CLIENT_ID"

// Ruler
#define kWidthOfRuler 70
#define kRulerPinchBuffer 40
#define kRulerSnapAngle M_PI / 45.0


// List View
#define kNumberOfColumnsInListView 3
#define kListPageZoom .25

// List View Gesture
#define kZoomToListPageZoom .4
#define kMinPageZoom .8
#define kMaxPageZoom 2.0
#define kMaxPageResolution 1.5

// Page View
#define kMaxScrapsInBezel 6
#define kGutterWidthToDragPages 500
#define kFingerWidth 40
#define kFilteringFactor 0.2
#define kStartOfSidebar 290
#define kWidthOfSidebarButton 60.0
#define kWidthOfSidebarButtonBuffer 10
#define kWidthOfSidebar 80
#define kMinScaleDelta .01
#define kShadowDepth 7
#define kShadowBend 3
#define kBezelInGestureWidth 40
#define kUndoLimit 10 // TODO: make sure this defines the jot undo level

// Camera
#define kCameraMargin 10
#define kCameraPositionUserDefaultKey @"com.milestonemade.preferredCameraPosition"

// Scraps
#define kScrapShadowBufferSize 4

// track social sharing availability
#define kMPShareStatusAvailable @"Available"
#define kMPShareStatusUnavailable @"Unavailable"
#define kMPShareStatusUnknown @"Unknown"

#define kMPShareStatusCloudKit @"Share Status: CloudKit"
#define kMPShareStatusFacebook @"Share Status: Facebook"
#define kMPShareStatusTwitter @"Share Status: Twitter"
#define kMPShareStatusEmail @"Share Status: Email"
#define kMPShareStatusSMS @"Share Status: SMS"
#define kMPShareStatusTencentWeibo @"Share Status: Tencent Weibo"
#define kMPShareStatusSinaWeibo @"Share Status: Sina Weibo"

// MixPanel People Properties
#define kMPStatScissorSegments @"Stat: Scissor Segment Count"
#define kMPStatScrapPathSegments @"Stat: Scrap Segment Count"
#define kMPStatSegmentTestCount @"Stat: Clipping Test Count"
#define kMPStatSegmentCompareCount @"Stat: Clipping Compare Count"
#define kMPPreferredLanguage @"Language"
#define kMPID @"Mixpanel ID"
#define kMPScreenScale @"Screen Scale"
#define kMPDurationAppOpen @"Duration App Open"
#define kMPNumberOfPages @"Number of Pages"
#define kMPFirstLaunchDate @"Date of First Launch"
#define kMPNumberOfScraps @"Number of Scraps"
#define kMPHasBookTurnedPage @"Has Ever Turned Page"
#define kMPHasReorderedPage @"Has Ever Reordered Page"
#define kMPHasAddedPage @"Has Ever Added Page"
#define kMPNumberOfPenUses @"Number of Pen Uses"
#define kMPNumberOfEraserUses @"Number of Eraser Uses"
#define kMPNumberOfScissorUses @"Number of Scissor Uses"
#define kMPNumberOfRulerUses @"Number of Ruler Uses"
#define kMPNumberOfImports @"Number of Imports"
#define kMPNumberOfCloudKitImports @"Number of CloudKit Imports"  // import page sent via cloudkit
#define kMPNumberOfPhotoImports @"Number of Photo Imports"  // import existing photo
#define kMPNumberOfPhotosTaken @"Number of Photos Taken"    // take new photo with camera
#define kMPNumberOfExports @"Number of Exports"
#define kMPNumberOfCloudKitExports @"Number of CloudKit Exports"
#define kMPNumberOfOpenInExports @"Number of Open In Exports"
#define kMPNumberOfSocialExports @"Number of Social Media Exports"
#define kMPHasZoomedToList @"Has Zoomed Out to List"
#define kMPHasZoomedToPage @"Has Zoomed Into Page"
#define kMPHasDeletedPage @"Has Deleted Page"
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

// cloudkit tutorial
#define kMPHasFinishedTutorial @"Has Finished Tutorial"
#define kMPDurationWatchingTutorial @"Duration Watching Tutorial"

// invite properties
#define kMPEventInvite @"Invite Friend"
#define kMPEventInvitePropDestination @"Invite Destination"
#define kMPEventInvitePropResult @"Invite Result"

// MixPanel Error Events
#define kMPEventMemoryWarning @"Memory Warning"
#define kMPEventCrash @"Crash Report"
#define kMPEventGestureBug @"Gesture Bug"
#define kMPSaveFailedNeedsRetry @"Save Failed Will Retry"

// MixPanel Events Properties
#define kMPEventLaunch @"App Launch"
#define kMPEventResume @"App Resume"
#define kMPEventTakePhoto @"Take Photo"
#define kMPEventImportPhoto @"Import Photo"
#define kMPEventImportPage @"Import Page"
#define kMPEventImportPhotoFailed @"Import Photo Failed"
#define kMPEventExport @"Export Page"

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

// page cache manager
#define kPageCacheManagerHasLoadedAnyPage @"PageCacheManagerLoadedFirstPage"

#define RandomPhotoRotation(a) (^float(NSInteger b){srand((unsigned)b); float output = ((float)(rand() % kMaxPhotoRotationInDegrees - kMaxPhotoRotationInDegrees/2)) / 360.0 * M_PI; srand((unsigned)time(NULL)); return output;})(a)

// cache sizes
#define kMMLoadImageCacheSize 10
#define kMMPageCacheManagerSize 1

#ifdef __cplusplus
extern "C" {
#endif


    CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

    CGFloat SquaredDistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);

    CGPoint NormalizePointTo(CGPoint point1, CGSize size);
    
    CGPoint DenormalizePointTo(CGPoint point1, CGSize size);
    
    CGPoint AveragePoints(CGPoint point1, CGPoint point2);
    
#ifdef __cplusplus
}
#endif

    
enum {
    MMBezelDirectionNone = 0,
    MMBezelDirectionRight  = 1 << 0,
    MMBezelDirectionLeft   = 1 << 1,
    MMBezelDirectionUp    = 1 << 2,
    MMBezelDirectionDown = 1 << 3
};
typedef NSUInteger MMBezelDirection;

enum {
    MMScaleDirectionNone = 0,
    MMScaleDirectionLarger  = 1 << 0,
    MMScaleDirectionSmaller   = 1 << 1
};
typedef NSUInteger MMBezelScaleDirection;


#ifdef __cplusplus
extern "C" {
#endif
    
    typedef struct Quadrilateral{
        CGPoint upperLeft;
        CGPoint upperRight;
        CGPoint lowerRight;
        CGPoint lowerLeft;
    } Quadrilateral;
    
#ifdef __cplusplus
}  // extern "C"
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
    }  // extern "C"

#endif

    
    
#endif

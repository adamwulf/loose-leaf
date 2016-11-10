//
//  MMScapBubbleContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsInBezelContainerView.h"
#import "MMScrapBubbleButton.h"
#import "NSThread+BlockAdditions.h"
#import "MMCountableSidebarContentView.h"
#import "MMScrapsInSidebarState.h"
#import "MMImmutableScrapsOnPaperState.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMRotationManager.h"
#import "UIView+Debug.h"
#import "MMImmutableScrapsInSidebarState.h"
#import "MMTrashManager.h"


@implementation MMScrapsInBezelContainerView {
    CGFloat lastRotationReading;
    MMScrapsInSidebarState* sidebarScrapState;
    NSString* scrapIDsPath;

    NSMutableDictionary* rotationAdjustments;
}

@dynamic bubbleDelegate;
@synthesize sidebarScrapState;

- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)_countButton {
    if (self = [super initWithFrame:frame andCountButton:_countButton]) {
        contentView = [[MMCountableSidebarContentView alloc] initWithFrame:[slidingSidebarView contentBounds]];
        contentView.delegate = self;
        [slidingSidebarView addSubview:contentView];

        NSDictionary* loadedRotationValues = [NSDictionary dictionaryWithContentsOfFile:[MMScrapsInBezelContainerView pathToPlist]];
        rotationAdjustments = [NSMutableDictionary dictionary];
        if (loadedRotationValues) {
            [rotationAdjustments addEntriesFromDictionary:loadedRotationValues];
        }

        sidebarScrapState = [[MMScrapsInSidebarState alloc] initWithDelegate:self];
    }
    return self;
}

#pragma mark - Helper Methods

- (NSString*)scrapIDsPath {
    if (!scrapIDsPath) {
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"Bezel"];
        [NSFileManager ensureDirectoryExistsAtPath:bezelStateDirectory];
        scrapIDsPath = [[bezelStateDirectory stringByAppendingPathComponent:@"scrapIDs"] stringByAppendingPathExtension:@"plist"];
    }
    return scrapIDsPath;
}


#pragma mark - Actions

- (void)bubbleTapped:(UITapGestureRecognizer*)gesture {
    MMScrapBubbleButton* bubble = (MMScrapBubbleButton*)gesture.view;
    MMScrapView* scrap = bubble.view;

    if ([[self viewsInSidebar] containsObject:bubble.view]) {
        scrap.rotation += (bubble.rotation - bubble.rotationAdjustment);
        [rotationAdjustments removeObjectForKey:scrap.uuid];
    }

    [super bubbleTapped:gesture];
}

#pragma mark - MMCountableSidebarContainerView

- (CGSize)sizeForButton {
    return CGSizeMake(80, 80);
}

- (MMScrapBubbleButton*)newBubbleForView:(MMScrapView*)scrap {
    CGSize sizeOfButton = [self sizeForButton];
    MMScrapBubbleButton* bubble = [[MMScrapBubbleButton alloc] initWithFrame:CGRectMake(0, 0, sizeOfButton.width, sizeOfButton.height)];
    bubble.rotation = lastRotationReading;
    bubble.originalViewScale = scrap.scale;
    bubble.delegate = self;
    [rotationAdjustments setObject:@(bubble.rotationAdjustment) forKey:scrap.uuid];
    return bubble;
}

- (void)addViewToCountableSidebar:(MMScrapView*)scrap animated:(BOOL)animated {
    // make sure we've saved its current state
    if (animated) {
        // only save when it's animated. non-animated is loading
        // from disk at start up
        [scrap saveScrapToDisk:nil];
    }

    [sidebarScrapState scrapIsAddedToSidebar:scrap];

    // unload the scrap state, so that it shows the
    // image preview instead of an editable state
    [scrap unloadState];

    [super addViewToCountableSidebar:scrap animated:animated];
}

- (NSDictionary*)idealPropertiesForViewInBubble:(MMScrapBubbleButton*)bubble {
    NSMutableDictionary* mproperties = [[super idealPropertiesForViewInBubble:bubble] mutableCopy] ?: [NSMutableDictionary dictionary];

    [mproperties setObject:[NSNumber numberWithFloat:bubble.view.rotation] forKey:@"rotation"];

    return mproperties;
}

- (void)didTapOnViewFromMenu:(MMScrapView*)view withPreferredProperties:(NSDictionary*)properties below:(BOOL)below {
    CheckMainThread;

    [sidebarScrapState scrapIsRemovedFromSidebar:view];

    [view loadScrapStateAsynchronously:YES];

    [super didTapOnViewFromMenu:view withPreferredProperties:properties below:below];
}


- (void)deleteAllViewsFromSidebar {
    for (MMScrapView* scrap in [[self viewsInSidebar] copy]) {
        [[MMTrashManager sharedInstance] deleteScrap:scrap.uuid inScrapCollectionState:scrap.state.scrapsOnPaperState];
        [sidebarScrapState scrapIsRemovedFromSidebar:scrap];
    }

    [super deleteAllViewsFromSidebar];

    [self saveScrapContainerToDisk];
}

- (void)loadCachedPreviewForView:(MMScrapView*)view {
    [view.state loadCachedScrapPreview];
}

- (void)unloadCachedPreviewForView:(MMScrapView*)view {
    [view.state unloadCachedScrapPreview];
}

#pragma mark - Rotation

- (CGFloat)sidebarButtonRotation {
    return -([[[MMRotationManager sharedInstance] currentRotationReading] angle] + M_PI / 2);
}

- (CGFloat)sidebarButtonRotationForReading:(MMVector*)currentReading {
    return -([currentReading angle] + M_PI / 2);
}

- (void)didUpdateAccelerometerWithReading:(MMVector*)currentRawReading {
    lastRotationReading = [self sidebarButtonRotationForReading:currentRawReading];
    CGFloat rotReading = [self sidebarButtonRotationForReading:currentRawReading];
    self.countButton.rotation = rotReading;
    self.countButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
    for (MMScrapBubbleButton* bubble in self.subviews) {
        if ([bubble conformsToProtocol:@protocol(MMBubbleButton)]) {
            // during an animation, the scrap will also be a subview,
            // so we need to make sure that we're rotating only the
            // bubble button
            bubble.rotation = rotReading;
        }
    }
    [contentView setRotation:rotReading];
}

#pragma mark - Save and Load


static NSString* bezelStatePath;


+ (NSString*)pathToPlist {
    if (!bezelStatePath) {
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"Bezel"];
        [NSFileManager ensureDirectoryExistsAtPath:bezelStateDirectory];
        bezelStatePath = [[bezelStateDirectory stringByAppendingPathComponent:@"rotations"] stringByAppendingPathExtension:@"plist"];
    }
    return bezelStatePath;
}

- (void)saveScrapContainerToDisk {
    CheckMainThread;
    if ([sidebarScrapState hasEditsToSave]) {
        NSMutableDictionary* writeableAdjustments = [rotationAdjustments copy];
        MMImmutableScrapCollectionState* immutableScrapState = [sidebarScrapState immutableStateForPath:self.scrapIDsPath];
        dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
            @autoreleasepool {
                [immutableScrapState saveStateToDiskBlocking];
                [writeableAdjustments writeToFile:[MMScrapsInBezelContainerView pathToPlist] atomically:YES];
            }
        });
    }
}

- (void)loadFromDisk {
    [sidebarScrapState loadStateAsynchronously:YES atPath:self.scrapIDsPath andMakeEditable:NO andAdjustForScale:NO];
}


#pragma mark - MMScrapsInSidebarStateDelegate / MMScrapCollectionStateDelegate

- (NSString*)uuidOfScrapCollectionStateOwner {
    return nil;
}

- (MMScrapView*)scrapForUUIDIfAlreadyExistsInOtherContainer:(NSString*)scrapUUID {
    // page's scraps might exist inside the bezel (us),
    // but our scraps will never exist on another page.
    // if our scraps are ever added to a page, they are
    // permanently gifted to that page's ownership, and
    // we lose our rights to it
    return nil;
}

- (void)didLoadScrapInContainer:(MMScrapView*)scrap {
    // add to the bezel
    NSNumber* rotationAdjustment = [rotationAdjustments objectForKey:scrap.uuid];
    scrap.rotation += [rotationAdjustment floatValue];
    [self addViewToCountableSidebar:scrap animated:NO];
    [scrap setShouldShowShadow:NO];
}

- (void)didLoadScrapOutOfContainer:(MMScrapView*)scrap {
    // noop
}

- (void)didLoadAllScrapsFor:(MMScrapCollectionState*)scrapState {
    // noop
}

- (void)didUnloadAllScrapsFor:(MMScrapCollectionState*)scrapState {
    // noop
}

- (MMScrapsOnPaperState*)paperStateForPageUUID:(NSString*)uuidOfPage {
    return [[self bubbleDelegate] pageForUUID:uuidOfPage].scrapsOnPaperState;
}

@end

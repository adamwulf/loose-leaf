//
//  MMPageCloner.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/20/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPageCloner.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMEditablePaperView.h"
#import <JotUI/JotUI.h>


@implementation MMPageCloner {
    BOOL didBeginClone;
    void (^onCloneComplete)(NSString* clonedUUID);
    BOOL didFinishClone;
}

- (instancetype)initWithOriginalUUID:(NSString*)originalPageUUID clonedUUID:(NSString*)cloneUUID inStackUUID:(NSString*)stackUUID {
    if (self = [super init]) {
        _stackUUID = stackUUID;
        _originalPageUUID = originalPageUUID;
        _cloneUUID = cloneUUID;
    }
    return self;
}

- (void)beginClone {
    CheckMainThread;

    if (!didBeginClone) {
        didBeginClone = YES;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString* pagesPath = [MMEditablePaperView pagesPathForStackUUID:_stackUUID andPageUUID:_originalPageUUID];
            NSString* bundledPath = [MMEditablePaperView bundledPagesPathForPageUUID:_originalPageUUID];
            NSString* destinationPath = [MMEditablePaperView pagesPathForStackUUID:_stackUUID andPageUUID:_cloneUUID];

            NSMutableArray* bundledContents = [[[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:bundledPath filesOnly:YES] mutableCopy];
            NSMutableArray* pagesContents = [[[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:pagesPath filesOnly:YES] mutableCopy];

            // don't copy items from the bundle that are already
            // overwritten in the modified page's contents
            [bundledContents removeObjectsInArray:pagesContents];

            void (^moveItemIntoLocation)(NSString*, NSString*) = ^(NSString* fromPath, NSString* targetPath) {
                NSError* err = nil;
                NSString* targetDirectory = [targetPath stringByDeletingLastPathComponent];
                [NSFileManager ensureDirectoryExistsAtPath:targetDirectory];

                [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:targetPath error:&err];

                NSAssert(!err, @"shouldn't have any problem copying files");
            };

            for (NSString* item in bundledContents) {
                NSString* fromPath = [bundledPath stringByAppendingPathComponent:item];
                NSString* targetPath = [destinationPath stringByAppendingPathComponent:item];
                moveItemIntoLocation(fromPath, targetPath);
            }

            for (NSString* item in pagesContents) {
                NSString* fromPath = [pagesPath stringByAppendingPathComponent:item];
                NSString* targetPath = [destinationPath stringByAppendingPathComponent:item];
                moveItemIntoLocation(fromPath, targetPath);
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                didFinishClone = YES;

                if (onCloneComplete) {
                    onCloneComplete(_cloneUUID);
                }
            });
        });
    }
}

- (void)finishCloneAndThen:(void (^)(NSString* clonedUUID))onComplete {
    CheckMainThread;

    if (onCloneComplete) {
        return;
    } else if (didFinishClone) {
        onComplete(_cloneUUID);
    } else {
        onCloneComplete = onComplete;
    }
}

- (void)abortClone {
    CheckMainThread;
    if (onCloneComplete) {
        return;
    } else {
        [self finishCloneAndThen:^(NSString* clonedUUID) {
            NSString* destinationPath = [MMEditablePaperView pagesPathForStackUUID:_stackUUID andPageUUID:_cloneUUID];
            [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
        }];
    }
}

@end

//
//  MMJotViewStateUpgrader.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/1/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMJotViewStateUpgrader.h"
#import <JotUI/JotUI.h>
#import "NSArray+Map.h"


@implementation MMJotViewStateUpgrader {
    NSString* pagesPath;
}

- (instancetype)initWithPagesPath:(NSString*)_pagesPath {
    if (self = [super init]) {
        pagesPath = _pagesPath;
    }
    return self;
}

- (NSString*)inkPath {
    return [[pagesPath stringByAppendingPathComponent:@"ink"] stringByAppendingPathExtension:@"png"];
}

- (NSString*)plistPath {
    return [[pagesPath stringByAppendingPathComponent:@"info"] stringByAppendingPathExtension:@"plist"];
}

- (void)upgradeWithCompletionBlock:(void (^)())onComplete {
    @autoreleasepool {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self plistPath]]) {
            dispatch_async([JotView importExportStateQueue], ^{
                // make this async so that we can update a progress bar
                CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];

                NSDictionary* stateInfo = [NSDictionary dictionaryWithContentsOfFile:[self plistPath]];

                if (stateInfo) {
                    // load our undo state if we have it
                    id (^loadStrokeBlock)(id obj, NSUInteger index) = ^id(id strokeProperties, NSUInteger index) {
                        NSString* filename = [[pagesPath stringByAppendingPathComponent:strokeProperties] stringByAppendingPathExtension:kJotStrokeFileExt];

                        if (![strokeProperties isKindOfClass:[NSDictionary class]]) {
                            strokeProperties = [NSDictionary dictionaryWithContentsOfFile:filename];
                        }

                        if (CGRectGetWidth(screenBounds) != 768 && CGRectGetHeight(screenBounds) != 1024) {
                            CGFloat widthRatio = CGRectGetWidth(screenBounds) / 768.0;
                            CGFloat heightRatio = CGRectGetHeight(screenBounds) / 1024.0;

                            NSMutableDictionary* modStrokeProperties = [strokeProperties mutableCopy];
                            modStrokeProperties[@"segments"] = [modStrokeProperties[@"segments"] mapObjectsUsingBlock:^id(id segmentProperties, NSUInteger idx) {
                                NSMutableDictionary* modSegmentProps = [segmentProperties mutableCopy];

                                if (modSegmentProps[@"startPoint.x"]) {
                                    modSegmentProps[@"startPoint.x"] = @([segmentProperties[@"startPoint.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"startPoint.y"] = @([segmentProperties[@"startPoint.y"] floatValue] * heightRatio);
                                }
                                if (modSegmentProps[@"ctrl1.x"]) {
                                    modSegmentProps[@"ctrl1.x"] = @([segmentProperties[@"ctrl1.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"ctrl1.y"] = @([segmentProperties[@"ctrl1.y"] floatValue] * heightRatio);
                                }
                                if (modSegmentProps[@"ctrl2.x"]) {
                                    modSegmentProps[@"ctrl2.x"] = @([segmentProperties[@"ctrl2.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"ctrl2.y"] = @([segmentProperties[@"ctrl2.y"] floatValue] * heightRatio);
                                }
                                if (modSegmentProps[@"curveTo.x"]) {
                                    modSegmentProps[@"curveTo.x"] = @([segmentProperties[@"curveTo.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"curveTo.y"] = @([segmentProperties[@"curveTo.y"] floatValue] * heightRatio);
                                }
                                if (modSegmentProps[@"p1.x"]) {
                                    modSegmentProps[@"p1.x"] = @([segmentProperties[@"p1.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"p1.y"] = @([segmentProperties[@"p1.y"] floatValue] * heightRatio);
                                }
                                if (modSegmentProps[@"p2.x"]) {
                                    modSegmentProps[@"p2.x"] = @([segmentProperties[@"p2.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"p2.y"] = @([segmentProperties[@"p2.y"] floatValue] * heightRatio);
                                }
                                if (modSegmentProps[@"p3.x"]) {
                                    modSegmentProps[@"p3.x"] = @([segmentProperties[@"p3.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"p3.y"] = @([segmentProperties[@"p3.y"] floatValue] * heightRatio);
                                }
                                if (modSegmentProps[@"p4.x"]) {
                                    modSegmentProps[@"p4.x"] = @([segmentProperties[@"p4.x"] floatValue] * widthRatio);
                                    modSegmentProps[@"p4.y"] = @([segmentProperties[@"p4.y"] floatValue] * heightRatio);
                                }
                                [modSegmentProps removeObjectForKey:@"numberOfBytesOfVertexData"];
                                [modSegmentProps removeObjectForKey:@"vertexBuffer"];

                                return modSegmentProps;
                            }];

                            [modStrokeProperties writeToFile:filename atomically:YES];
                        }

                        return strokeProperties;
                    };

                    [[stateInfo objectForKey:@"stackOfStrokes"] mapObjectsUsingBlock:loadStrokeBlock];
                    [[stateInfo objectForKey:@"stackOfUndoneStrokes"] mapObjectsUsingBlock:loadStrokeBlock];
                }

                dispatch_async(dispatch_get_main_queue(), onComplete);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), onComplete);
        }
    }
}

@end

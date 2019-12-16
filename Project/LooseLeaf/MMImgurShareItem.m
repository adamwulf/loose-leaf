//
//  MMImgurShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImgurShareItem.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "AFNetworking.h"
#import "MMReachabilityManager.h"
#import "Reachability.h"
#import "MMOfflineIconView.h"


@implementation MMImgurShareItem {
    AFURLConnectionOperation* conn;
    NSString* lastLinkURL;
    CGFloat lastProgress;
    CGFloat targetProgress;
    BOOL targetSuccess;
    NSError* reason;
}

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0, 0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"imgur"]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];

        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];

        [self updateButtonGreyscale];
    }
    return self;
}

- (MMSidebarButton*)button {
    return button;
}

- (NSString*)exportDestinationName {
    return @"Imgur";
}

- (NSString*)exportDestinationResult {
    return @"Success";
}

- (void)performShareAction {
    if (!button.greyscale) {
        if (targetProgress) {
            // only try to share if not already sharing
            return;
        }
        [delegate mayShare:self];
        // if a popover controller is dismissed, it
        // adds the dismissal to the main queue async
        // so we need to add our next steps /after that/
        // so we need to dispatch async too
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.delegate urlToShare]]];
                if (image && !conn) {
                    lastProgress = 0;
                    targetSuccess = 0;
                    targetProgress = 0;
                    reason = nil;
                    [self uploadPhoto:UIImagePNGRepresentation(image) title:@"Quick sketch from Loose Leaf" description:@"http://getlooseleaf.com" progressBlock:^(CGFloat progress) {
                        progress *= .55; // leave last 10 % for when we get the URL
                        if (progress > targetProgress) {
                            targetProgress = progress;
                        }
                        targetSuccess = YES;
                    } completionBlock:^(NSString* result) {
                        lastLinkURL = result;
                        targetProgress = 1.0;
                        targetSuccess = YES;
                        conn = nil;
                        reason = nil;
                        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
                        [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination: [self exportDestinationName],
                                                                                     kMPEventExportPropResult: [self exportDestinationResult]}];
                    } failureBlock:^(NSURLResponse* response, NSError* error, NSInteger status) {
                        lastLinkURL = nil;
                        targetProgress = 1.0;
                        targetSuccess = NO;
                        reason = error;
                        conn = nil;

                        NSString* failedReason = [error.userInfo valueForKey:NSLocalizedFailureReasonErrorKey];
                        if (failedReason) {
                            [[Mixpanel sharedInstance] track:kMPEventExport properties:@{ kMPEventExportPropDestination: [self exportDestinationName],
                                                                                          kMPEventExportPropResult: @"Failed",
                                                                                          kMPEventExportPropReason: failedReason }];
                        } else {
                            [[Mixpanel sharedInstance] track:kMPEventExport properties:@{ kMPEventExportPropDestination: [self exportDestinationName],
                                                                                          kMPEventExportPropResult: @"Failed" }];
                        }
                    }];
                    [self animateToPercent:.1 success:YES];
                }
            }
        });
    } else {
        [self animateToPercent:1.0 success:NO];
    }
}


- (void)animateLinkTo:(NSString*)linkURL {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = lastLinkURL;
    [self animateCompletionText:@"Link copied to clipboard" withImage:[UIImage imageNamed:@"link"]];
}

- (void)animateToPercent:(CGFloat)progress success:(BOOL)succeeded {
    targetProgress = progress;
    targetSuccess = succeeded;

    if (lastProgress < targetProgress) {
        lastProgress += (targetProgress / 10.0);
        if (lastProgress > targetProgress) {
            lastProgress = targetProgress;
        }
    }

    CGPoint center = CGPointMake(CGRectGetMidX(button.drawableFrame), CGRectGetMidY(button.drawableFrame));

    CGFloat radius = ceilf(button.drawableFrame.size.width / 2);
    CAShapeLayer* circle;
    if ([button.layer.sublayers count] && [[button.layer.sublayers firstObject] isKindOfClass:[CAShapeLayer class]]) {
        circle = (CAShapeLayer*)[button.layer.sublayers firstObject];
    }

    if (!circle) {
        circle = [CAShapeLayer layer];
        circle.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2 * M_PI * 0 - M_PI_2 endAngle:2 * M_PI * 1 - M_PI_2 clockwise:YES].CGPath;
        circle.fillColor = [UIColor clearColor].CGColor;
        circle.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:.7].CGColor;
        circle.lineWidth = radius * 2;
        CAShapeLayer* mask = [CAShapeLayer layer];
        mask.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 1.5 startAngle:2 * M_PI * 0 - M_PI_2 endAngle:2 * M_PI * 1 - M_PI_2 clockwise:YES].CGPath;
        circle.mask = mask;
        [button.layer addSublayer:circle];
    }

    circle.strokeEnd = lastProgress;

    if (lastProgress >= 1.0) {
        CAShapeLayer* mask2 = [CAShapeLayer layer];
        mask2.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 1.5 startAngle:2 * M_PI * 0 - M_PI_2 endAngle:2 * M_PI * 1 - M_PI_2 clockwise:YES].CGPath;

        UIView* checkOrXView = [[UIView alloc] initWithFrame:button.bounds];
        checkOrXView.backgroundColor = [UIColor whiteColor];
        checkOrXView.layer.mask = mask2;

        [[NSThread mainThread] performBlock:^{
            CAShapeLayer* checkMarkOrXLayer = [CAShapeLayer layer];
            checkMarkOrXLayer.anchorPoint = CGPointZero;
            checkMarkOrXLayer.bounds = button.bounds;
            UIBezierPath* path = nil;
            if (succeeded) {
                path = [UIBezierPath bezierPath];
                CGPoint start = CGPointMake(28, 39);
                CGPoint corner = CGPointMake(start.x + 6, start.y + 6);
                CGPoint end = CGPointMake(corner.x + 14, corner.y - 14);
                [path moveToPoint:start];
                [path addLineToPoint:corner];
                [path addLineToPoint:end];
                [self animateLinkTo:lastLinkURL];
            } else if ([MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable &&
                       reason.code != NSURLErrorNotConnectedToInternet) {
                path = [UIBezierPath bezierPath];
                CGFloat size = 14;
                CGPoint start = CGPointMake(31, 31);
                CGPoint end = CGPointMake(start.x + size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
                start = CGPointMake(start.x + size, start.y);
                end = CGPointMake(start.x - size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
            } else {
                CGRect iconFrame = CGRectInset(button.drawableFrame, 6, 6);
                iconFrame.origin.y += 4;
                MMOfflineIconView* offlineIcon = [[MMOfflineIconView alloc] initWithFrame:iconFrame];
                offlineIcon.shouldDrawOpaque = YES;
                [checkOrXView addSubview:offlineIcon];
            }

            if (path) {
                checkMarkOrXLayer.path = path.CGPath;
                checkMarkOrXLayer.strokeColor = [UIColor blackColor].CGColor;
                checkMarkOrXLayer.lineWidth = 6;
                checkMarkOrXLayer.lineCap = @"square";
                checkMarkOrXLayer.strokeStart = 0;
                checkMarkOrXLayer.strokeEnd = 1;
                checkMarkOrXLayer.backgroundColor = [UIColor clearColor].CGColor;
                checkMarkOrXLayer.fillColor = [UIColor clearColor].CGColor;
                [checkOrXView.layer addSublayer:checkMarkOrXLayer];
            }

            checkOrXView.alpha = 0;
            [button addSubview:checkOrXView];
            [UIView animateWithDuration:.3 animations:^{
                checkOrXView.alpha = 1;
            } completion:^(BOOL finished) {
                if (succeeded) {
                    [delegate didShare:self];
                }
                [[NSThread mainThread] performBlock:^{
                    [checkOrXView.layer insertSublayer:circle atIndex:0];
                    [UIView animateWithDuration:.3 animations:^{
                        checkOrXView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [checkOrXView removeFromSuperview];
                        [circle removeAnimationForKey:@"drawCircleAnimation"];
                        [circle removeFromSuperlayer];
                        // reset state
                        lastProgress = 0;
                        targetSuccess = 0;
                        targetProgress = 0;
                    }];
                } afterDelay:1];
            }];
        } afterDelay:.3];
    } else {
        [[NSThread mainThread] performBlock:^{
            [self animateToPercent:targetProgress success:targetSuccess];
        } afterDelay:.03];
    }
}

- (BOOL)isAtAllPossibleForMimeType:(NSString*)mimeType {
    return [mimeType hasPrefix:@"image"];
}

#pragma mark - Upload

- (void)uploadPhoto:(NSData*)imageData
              title:(NSString*)title
        description:(NSString*)description
      progressBlock:(void (^)(CGFloat progress))progressBlock
    completionBlock:(void (^)(NSString* result))completionBlock
       failureBlock:(void (^)(NSURLResponse* response, NSError* error, NSInteger status))failureBlock {
    NSAssert(imageData, @"Image data is required");

    NSString* urlString = @"https://api.imgur.com/3/upload.json";
    //    NSString *urlString = @"https://imgur-apiv3.p.mashape.com/3/upload.json";
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    NSMutableData* requestBody = [[NSMutableData alloc] init];

    NSString* boundary = @"---------------------------0983745982375409872438752038475287";

    NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

    // Add client ID as authrorization header
    [request addValue:[NSString stringWithFormat:@"Client-ID %@", kImgurClientID] forHTTPHeaderField:@"Authorization"];
    [request addValue:[NSString stringWithFormat:kMashapeClientID] forHTTPHeaderField:@"X-Mashape-Key"];

    // Image File Data
    [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [requestBody appendData:[@"Content-Disposition: attachment; name=\"image\"; filename=\".tiff\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [requestBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [requestBody appendData:[NSData dataWithData:imageData]];
    [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    // Title parameter
    if (title) {
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"title\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[title dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // Description parameter
    if (title) {
        [requestBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[description dataUsingEncoding:NSUTF8StringEncoding]];
        [requestBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [requestBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:requestBody];
    [request setTimeoutInterval:10];


    conn = [[AFURLConnectionOperation alloc] initWithRequest:request];
    __weak AFURLConnectionOperation* blockConn = conn;
    [conn setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressBlock((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
    }];
    [conn setCompletionBlock:^{
        if (completionBlock) {
            NSDictionary* responseDictionary = nil;
            if (blockConn.responseData) {
                responseDictionary = [NSJSONSerialization JSONObjectWithData:blockConn.responseData options:NSJSONReadingMutableContainers error:nil];
            }
            if ([responseDictionary valueForKeyPath:@"data.link"]) {
                if (completionBlock) {
                    completionBlock([responseDictionary valueForKeyPath:@"data.link"]);
                }
            } else {
                if (failureBlock) {
                    NSError* error = blockConn.error;
                    if (!error) {
                        NSString* errStr = [responseDictionary valueForKeyPath:@"data.error"];
                        if ([responseDictionary valueForKey:@"message"]) {
                            errStr = [responseDictionary valueForKeyPath:@"message"];
                        }
                        // If no error has been provided, create one based on the response received from the server
                        error = [NSError errorWithDomain:@"imguruploader" code:10000 userInfo:errStr ? @{NSLocalizedFailureReasonErrorKey: errStr} : nil];
                    }

                    failureBlock(blockConn.response, error, [[responseDictionary valueForKey:@"status"] intValue]);
                }
            }
        }
    }];
    [conn start];
}


#pragma mark - Notification

- (void)updateButtonGreyscale {
    if (![self.delegate urlToShare]) {
        button.greyscale = YES;
    } else if ([MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable) {
        button.greyscale = NO;
    } else {
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

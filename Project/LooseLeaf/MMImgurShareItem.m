//
//  MMImgurShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImgurShareItem.h"
#import "MMTextButton.h"
#import "MMImageViewButton.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "AFNetworking.h"
#import "MMReachabilityManager.h"
#import "Reachability.h"

@implementation MMImgurShareItem{
    MMImageViewButton* button;
    AFURLConnectionOperation* conn;
    NSString* lastLinkURL;
    CGFloat lastProgress;
    CGFloat targetProgress;
    BOOL targetSuccess;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"imgur"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateButtonGreyscale)
                                                     name:kReachabilityChangedNotification object:nil];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateButtonGreyscale];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    UIImage* image = self.delegate.imageToShare;
    if(image && !conn && [MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable){
        lastProgress = 0;
        targetSuccess = 0;
        targetProgress = 0;
        [self uploadPhoto:UIImagePNGRepresentation(image) title:@"Quick sketch from Loose Leaf" description:@"http://getlooseleaf.com" progressBlock:^(CGFloat progress) {
            progress *= .55; // leave last 10 % for when we get the URL
            if(progress > targetProgress){
                targetProgress = progress;
            }
            targetSuccess = YES;
        } completionBlock:^(NSString *result) {
            lastLinkURL = result;
            targetProgress = 1.0;
            targetSuccess = YES;
            conn = nil;
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
            [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Imgur",
                                                                         kMPEventExportPropResult : @"Success"}];
        } failureBlock:^(NSURLResponse *response, NSError *error, NSInteger status) {
            lastLinkURL = nil;
            targetProgress = 1.0;
            targetSuccess = NO;
            conn = nil;
            
            NSString* failedReason = [error.userInfo valueForKey:NSLocalizedFailureReasonErrorKey];
            if(failedReason){
                [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Imgur",
                                                                             kMPEventExportPropResult : @"Failed",
                                                                             kMPEventExportPropReason : failedReason}];
            }else{
                [[Mixpanel sharedInstance] track:kMPEventExport properties:@{kMPEventExportPropDestination : @"Imgur",
                                                                             kMPEventExportPropResult : @"Failed"}];
            }
        }];
        [self animateToPercent:.1 success:YES];
    }
}


-(void) animateLinkTo:(NSString*) linkURL{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = linkURL;
    
    linkURL = [@"        " stringByAppendingString:linkURL];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    imgView.image = [UIImage imageNamed:@"link"];
    
    UILabel* labelForLink = [[UILabel alloc] initWithFrame:CGRectZero];
    labelForLink.alpha = 0;
    labelForLink.text = linkURL;
    labelForLink.font = [UIFont boldSystemFontOfSize:16];
    labelForLink.textAlignment = NSTextAlignmentCenter;
    labelForLink.textColor = [UIColor whiteColor];
    labelForLink.clipsToBounds = YES;
    labelForLink.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75];
    labelForLink.layer.borderColor = [UIColor whiteColor].CGColor;
    labelForLink.layer.borderWidth = 1.0;
    labelForLink.layer.cornerRadius = 20;
    [labelForLink sizeToFit];
    CGRect winFr = self.button.window.bounds;
    CGRect fr = labelForLink.frame;
    fr.size.height = 40;
    fr.size.width += 40;
    fr.origin.x = (winFr.size.width - fr.size.width) / 2;
    fr.origin.y = 40;
    labelForLink.frame = fr;
    [labelForLink addSubview:imgView];
    [self.button.window addSubview:labelForLink];
    
    [UIView animateWithDuration:.3 animations:^{
        labelForLink.alpha = 1;
    }completion:^(BOOL finished){
        [[NSThread mainThread] performBlock:^{
            [UIView animateWithDuration:.3 animations:^{
                labelForLink.alpha = 0;
            }completion:^(BOOL finished){
                [labelForLink removeFromSuperview];
            }];
        } afterDelay:1.2];
    }];
    
}

-(void) animateToPercent:(CGFloat)progress success:(BOOL)succeeded{
    targetProgress = progress;
    targetSuccess = succeeded;
    
    if(lastProgress < targetProgress){
        lastProgress += (targetProgress / 10.0);
        if(lastProgress > targetProgress){
            lastProgress = targetProgress;
        }
    }

    CGPoint center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2);

    CGFloat radius = button.drawableFrame.size.width / 2;
    CAShapeLayer *circle;
    if([button.layer.sublayers count]){
        circle = [button.layer.sublayers firstObject];
    }else{
        circle=[CAShapeLayer layer];
        circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.fillColor=[UIColor clearColor].CGColor;
        circle.strokeColor=[UIColor whiteColor].CGColor;
        circle.lineWidth=radius*2;
        CAShapeLayer *mask=[CAShapeLayer layer];
        mask.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.mask = mask;
        [button.layer addSublayer:circle];
    }

    circle.strokeEnd = lastProgress;
    
    if(lastProgress >= 1.0){
        UILabel* label = [[UILabel alloc] initWithFrame:button.bounds];
        
        [[NSThread mainThread] performBlock:^{
            if(succeeded){
                label.text = @"\u2714";
                [self animateLinkTo:lastLinkURL];
            }else{
                label.text = @"\u2718";
            }
            label.font = [UIFont fontWithName:@"ZapfDingbatsITC" size:30];
            label.textAlignment = NSTextAlignmentCenter;
            label.alpha = 0;
            [button addSubview:label];
            [UIView animateWithDuration:.3 animations:^{
                label.alpha = 1;
            } completion:^(BOOL finished){
                [delegate didShare];
                [[NSThread mainThread] performBlock:^{
                    [label removeFromSuperview];
                    [circle removeAnimationForKey:@"drawCircleAnimation"];
                    [circle removeFromSuperlayer];
                } afterDelay:.5];
            }];
        } afterDelay:.3];
    }else{
        [[NSThread mainThread] performBlock:^{
            [self animateToPercent:targetProgress success:targetSuccess];
        } afterDelay:.03];
    }

}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Upload

- (void)uploadPhoto:(NSData*)imageData
              title:(NSString*)title
        description:(NSString*)description
      progressBlock:(void(^)(CGFloat progress))progressBlock
    completionBlock:(void(^)(NSString* result))completionBlock
       failureBlock:(void(^)(NSURLResponse *response, NSError *error, NSInteger status))failureBlock
{
    NSAssert(imageData, @"Image data is required");
    
//    NSString *urlString = @"https://api.imgur.com/3/upload.json";
    NSString *urlString = @"https://imgur-apiv3.p.mashape.com/3/upload.json";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *requestBody = [[NSMutableData alloc] init];
    
    NSString *boundary = @"---------------------------0983745982375409872438752038475287";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
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
        if(completionBlock){
            NSDictionary *responseDictionary = nil;
            if(blockConn.responseData){
                responseDictionary = [NSJSONSerialization JSONObjectWithData:blockConn.responseData options:NSJSONReadingMutableContainers error:nil];
            }
            if([responseDictionary valueForKeyPath:@"data.link"]){
                if (completionBlock) {
                    completionBlock([responseDictionary valueForKeyPath:@"data.link"]);
                }
            }else{
                if (failureBlock) {
                    NSError* error = blockConn.error;
                    if (!error) {
                        NSString* errStr = [responseDictionary valueForKeyPath:@"data.error"];
                        if([responseDictionary valueForKey:@"message"]){
                            errStr = [responseDictionary valueForKeyPath:@"message"];
                        }
                        // If no error has been provided, create one based on the response received from the server
                        error = [NSError errorWithDomain:@"imguruploader" code:10000 userInfo:errStr ? @{NSLocalizedFailureReasonErrorKey : errStr} : nil];
                    }

                    failureBlock(blockConn.response, error, [[responseDictionary valueForKey:@"status"] intValue]);
                }
            }
        }
    }];
    [conn start];
}


#pragma mark - Notification

-(void) updateButtonGreyscale{
    if([MMReachabilityManager sharedManager].currentReachabilityStatus != NotReachable) {
        button.greyscale = NO;
    }else{
        button.greyscale = YES;
    }
    [button setNeedsDisplay];
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

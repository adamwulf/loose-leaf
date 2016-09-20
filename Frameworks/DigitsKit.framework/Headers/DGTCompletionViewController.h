//
//  DGTCompletionViewController.h
//  DigitsKit
//
//  Copyright (c) 2015 Twitter Inc. All rights reserved.
//

@class DGTSession;

/**
 * This protocol is to be implemented by an UIViewController that is pushed into the navigation stack after the Digits non-modal flow is completed.
 */
@protocol DGTCompletionViewController <NSObject>

/*
 * It is called after the Digits auth flow has completed with a success or failure before the ViewController
 * is pushed into your UINavigationController and `viewDidLoad` is called.
 */
-(void)digitsAuthenticationFinishedWithSession:(DGTSession *)session error:(NSError *)error;

@end

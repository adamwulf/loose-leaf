//
//  MMReleaseNotesViewController.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMReleaseNotesViewController : UIViewController

- (instancetype)initWithReleaseNotes:(NSString*)releaseNotes andCompletionBlock:(void (^)())completionBlock;

@end

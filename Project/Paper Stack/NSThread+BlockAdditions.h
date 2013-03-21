//
//  NSThread+BlockAdditions.h
//  PaintingSample
//
//  Created by Adam Wulf on 9/7/12.
//
//

#import <Foundation/Foundation.h>

@interface NSThread (BlockAdditions)

+(CGFloat) timeBlock:(void (^)())block;

- (void)performBlock:(void (^)())block;
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait;
+ (void)performBlockInBackground:(void (^)())block;
+ (void)performBlockOnMainThread:(void (^)())block;
- (void) performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay;
@end

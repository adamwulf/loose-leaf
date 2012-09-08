//
//  NSThread+BlockAdditions.m
//  PaintingSample
//
//  Created by Adam Wulf on 9/7/12.
//
//

#import "NSThread+BlockAdditions.h"


@implementation NSThread (BlocksAdditions)
- (void)performBlock:(void (^)())block
{
	if ([[NSThread currentThread] isEqual:self])
		block();
	else
		[self performBlock:block waitUntilDone:NO];
}
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait
{
    [NSThread performSelector:@selector(ng_runBlock:)
                     onThread:self
                   withObject:[[block copy] autorelease]
                waitUntilDone:wait];
}
+ (void)ng_runBlock:(void (^)())block
{
	block();
}
+ (void)performBlockInBackground:(void (^)())block
{
	[NSThread performSelectorInBackground:@selector(ng_runBlock:)
	                           withObject:[[block copy] autorelease]];
}
+ (void)performBlockOnMainThread:(void (^)())block
{
	if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void) performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay{
    [self performSelector: @selector(performBlock:) withObject: [[block copy] autorelease] afterDelay: delay];
}
@end

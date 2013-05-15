//
//  NSThread+BlockAdditions.m
//  PaintingSample
//
//  Created by Adam Wulf on 9/7/12.
//
//

#import "NSThread+BlockAdditions.h"
#import <mach/mach_time.h>  // for mach_absolute_time() and friends

@interface NSThread (Private)

CGFloat BNRTimeBlock (void (^block)(void));

@end

@implementation NSThread (BlockAdditions)

+(CGFloat) timeBlock:(void (^)())block{
    return BNRTimeBlock(block);
}

CGFloat BNRTimeBlock (void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
    
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
    
    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
    
} // BNRTimeBlock


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
                   withObject:[block copy]
                waitUntilDone:wait];
}
+ (void)ng_runBlock:(void (^)())block
{
	block();
}
+ (void)performBlockInBackground:(void (^)())block
{
	[NSThread performSelectorInBackground:@selector(ng_runBlock:)
	                           withObject:[block copy]];
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
    [self performSelector: @selector(performBlock:) withObject: [block copy] afterDelay: delay];
}
@end
//
//  NSThread+BlocksAdditions.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "NSThread+BlocksAdditions.h"

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
    if([NSThread isMainThread]){
        block();
    }else{
        [NSThread performSelector:@selector(ng_runBlock:)
                         onThread:[NSThread mainThread]
                       withObject:[[block copy] autorelease]
                    waitUntilDone:NO];
    }
}
@end

//
//  NSString+Contains.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/4/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "NSString+Contains.h"
#import <objc/runtime.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000


@implementation NSString (Contains)


+ (void)load {
    @autoreleasepool {
        [self pspdf_modernizeSelector:NSSelectorFromString(@"containsString:") withSelector:@selector(pspdf_containsString:)];
    }
}

+ (void)pspdf_modernizeSelector:(SEL)originalSelector withSelector:(SEL)newSelector {
    if (![NSString instancesRespondToSelector:originalSelector]) {
        Method newMethod = class_getInstanceMethod(self, newSelector);
        class_addMethod(self, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    }
}

// containsString: has been added in iOS 8. We dynamically add this if we run on iOS 7.
- (BOOL)pspdf_containsString:(NSString*)aString {
    return [self rangeOfString:aString].location != NSNotFound;
}


@end

#endif

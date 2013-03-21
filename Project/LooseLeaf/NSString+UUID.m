//
//  NSString+UUID.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/25/12.
//
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString*) createStringUUID {
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}

@end

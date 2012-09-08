//
//  PaintLayer.m
//  PaintingSample
//
//  Created by Adam Wulf on 9/8/12.
//
//

#import "PaintLayer.h"

@implementation PaintLayer


-(id<CAAction>) actionForKey:(NSString *)event{
    // disable default animations for this layer's contents
    if(NO && [event isEqualToString:@"contents"]){
        return nil;
    }
    return [super actionForKey:event];
}



@end

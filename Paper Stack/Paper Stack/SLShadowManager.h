//
//  SLShadowManager.h
//  scratchpaper
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLShadowManager : NSObject{
    NSMutableDictionary* shadowPathCache;
    UIBezierPath* unitShadowPath;
}

+(SLShadowManager*) sharedInstace;

-(void) beginGeneratingShadows;
-(CGPathRef) getShadowForSize:(CGSize)size;

@end

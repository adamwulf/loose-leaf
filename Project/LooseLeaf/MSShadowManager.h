//
//  SLShadowManager.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MSShadowManager : NSObject{
    NSMutableDictionary* shadowPathCache;
    UIBezierPath* unitShadowPath;
}

+(MSShadowManager*) sharedInstace;

-(void) beginGeneratingShadows;
-(CGPathRef) getShadowForSize:(CGSize)size;

@end

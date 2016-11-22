//
//  NRTextTransitionCompletionManager.h
//  NRTextTransitionsExample
//
//  Created by Natan Rolnik on 2/26/14.
//
//

#import <Foundation/Foundation.h>


@interface NRTextTransitionCompletionManager : NSObject

+ (id)sharedManager;
- (void)setCompletionBlock:(void (^)(void))completion forKey:(NSString*)key;

@end

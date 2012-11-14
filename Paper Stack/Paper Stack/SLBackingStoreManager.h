//
//  SLBackingStoreManager.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/13/12.
//
//

#import <Foundation/Foundation.h>
#import "SLBackingStoreManagerDelegate.h"

@interface SLBackingStoreManager : NSObject{
    NSOperationQueue* opQueue;
    
    NSObject<SLBackingStoreManagerDelegate>* delegate;
}

@property (nonatomic, readonly) NSOperationQueue* opQueue;
@property (nonatomic, assign) NSObject<SLBackingStoreManagerDelegate>* delegate;

+(SLBackingStoreManager*) sharedInstace;

@end

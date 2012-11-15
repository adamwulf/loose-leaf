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
    
    
    //
    // if this works, then i need to refactor
    // to support arbitrary malloc'd void*
    // instead of assuming they're all the same
    // size
    NSMutableSet* setOfPointers;
}

@property (nonatomic, readonly) NSOperationQueue* opQueue;
@property (nonatomic, assign) NSObject<SLBackingStoreManagerDelegate>* delegate;

+(SLBackingStoreManager*) sharedInstace;

-(void*) getZerodPointerForMemory:(int) size;
-(void*) getPointerForMemory:(int) size;
-(void) givePointerForMemory:(void*)ptr;

-(void) didReceiveMemoryWarning;

@end

//
//  SLBackingStoreDelegate.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/13/12.
//
//

#import <Foundation/Foundation.h>

@class SLBackingStore;

@protocol SLBackingStoreDelegate <NSObject>

-(void) didLoadBackingStore:(SLBackingStore*)backingStore;

-(void) didSaveBackingStore:(SLBackingStore*)backingStore;

@end

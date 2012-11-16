//
//  SLBackingStoreDelegate.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/13/12.
//
//

#import <Foundation/Foundation.h>

@class SLBackingStore;

@protocol SLBackingStoreManagerDelegate <NSObject>

-(void) willLoadBackingStore:(SLBackingStore*)backingStore;

-(void) didLoadBackingStore:(SLBackingStore*)backingStore;

-(void) willSaveBackingStore:(SLBackingStore*)backingStore;

-(void) didSaveBackingStore:(SLBackingStore*)backingStore withImage:(UIImage*)img;

@end
